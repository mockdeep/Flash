# frozen_string_literal: true

class Study
  ACTIVE_CARD_THRESHOLD = 20
  FUZZY_FIND_LEVEL = 3
  READING_LEVEL = 2
  Result =
    Data.define(
      :card,
      :correct,
      :correct_answer,
      :question,
      :selected_answer,
      :possible_answers,
      :card_completed,
      :level_completed,
      :reading_passed,
    ) do
      def initialize(reading_passed: false, **rest) = super
      def correct? = correct
      def card_completed? = card_completed
      def level_completed? = level_completed
      def reading_passed? = reading_passed
    end

  attr_accessor :deck, :next_card, :reading_confirmed

  def self.for(deck:, exclude_card_id: nil, card_id: nil)
    klass = deck.music? ? MusicStudy : self
    klass.new(deck:, exclude_card_id:, card_id:)
  end

  # A card_id pins the study to that card's translation question - the render
  # that follows a passed reading stage.
  def initialize(deck:, exclude_card_id: nil, card_id: nil)
    self.deck = deck
    self.reading_confirmed = !card_id.nil?
    self.next_card =
      card_id ? deck.cards.find(card_id) : pick_next_card(exclude_card_id:)
  end

  def reading_confirmed? = reading_confirmed

  def active_card_threshold
    (2**(deck.level - 1)) * ACTIVE_CARD_THRESHOLD
  end

  def pick_next_card(exclude_card_id:)
    pool = deck.cards.not_done(deck.level).ordered.limit(active_card_threshold)
    pool.where.not(id: exclude_card_id).sample || pool.sample
  end

  def presentation_mode
    if reading_stage?
      :reading
    elsif deck.level >= FUZZY_FIND_LEVEL
      :fuzzy_find
    else
      :multiple_choice
    end
  end

  def record_answer(params)
    permitted =
      params
        .expect(answer: [:card_id, :answer, :stage, { possible_answers: [] }])
    answer = permitted.to_h.symbolize_keys
    stage = answer.delete(:stage)
    stage == "reading" ? answer_reading(**answer) : answer_card(**answer)
  end

  def possible_answers
    return [] if next_card.nil?

    case presentation_mode
    when :fuzzy_find then fuzzy_answers
    when :reading then reading_answers
    else multiple_choice_answers
    end
  end

  # The reading stage gates the translation question but never scores it: a
  # pass writes nothing (answer_card does the bookkeeping), a miss resets the
  # streak without recording a translation distractor.
  def answer_reading(card_id:, answer:, possible_answers: [])
    card = deck.cards.find(card_id)
    correct = card.reading == answer
    unless correct
      card.view_count += 1
      card.correct_streak = 0
      card.save!
    end
    Result.new(
      card:,
      correct:,
      correct_answer: card.reading,
      question: card.front,
      selected_answer: answer,
      possible_answers: [*possible_answers, card.reading].uniq,
      card_completed: false,
      level_completed: false,
      reading_passed: correct,
    )
  end

  def answer_card(card_id:, answer:, possible_answers: [])
    card = deck.cards.find(card_id)
    card.view_count += 1
    result_answers = [*possible_answers, card.back].uniq
    if card.back == answer
      card.correct_count += 1
      card.correct_streak += 1
      card_completed = card.done?
      card.save!
      level_completed = card_completed && deck.cards.not_done(deck.level).none?
      deck.update!(level: deck.level + 1) if level_completed
      Result.new(
        card:,
        correct: true,
        correct_answer: card.back,
        question: card.front,
        selected_answer: answer,
        possible_answers: result_answers,
        card_completed:,
        level_completed:,
      )
    else
      ActiveRecord::Base.transaction do
        card.correct_streak = 0
        card.save!
        DataSets::Projection.add_distractor(card, answer)
      end
      Result.new(
        card:,
        correct: false,
        correct_answer: card.back,
        question: card.front,
        selected_answer: answer,
        possible_answers: result_answers,
        card_completed: false,
        level_completed: false,
      )
    end
  end

  private

  def reading_stage?
    !reading_confirmed &&
      deck.level == READING_LEVEL &&
      deck.anchor_side == "Front" &&
      next_card&.reading.present?
  end

  # Decoys come from the siblings whose front character count is closest to
  # the prompt's (random tiebreak): a learner predicts the phoneme count from
  # the prompt, so a wrong-count option is a free elimination. Two slots
  # prefer same-count siblings sharing the prompt's first or last character -
  # those can't be eliminated by knowing that one character's reading.
  def reading_answers
    front = next_card.front
    pool = sibling_pool(next_card.reading)
    anchored = shared_character_decoys(pool, front)
    fillers = count_ranked(pool, front).map(&:last).uniq - anchored
    decoys = [*anchored, *fillers].first(4)
    [*decoys, next_card.reading].shuffle
  end

  # A slot takes a random sibling that shares its end character and matches
  # the prompt's character count exactly, so it blends in with the
  # count-matched fillers. (A single-character prompt can never anchor: a
  # same-count sibling sharing its character would be the prompt itself.)
  def shared_character_decoys(pool, front)
    peers = pool.select { |text, _| text.length == front.length }
    slots = [
      peers.select { |text, _| text.start_with?(front.chars.first) },
      peers.select { |text, _| text.end_with?(front.chars.last) },
    ]
    slots.filter_map { |pairs| pairs.sample&.last }.uniq
  end

  def count_ranked(pairs, front)
    pairs.sort_by { |text, _| [(text.length - front.length).abs, rand] }
  end

  # Sibling (front, reading) pairs with a reading; homophones of the correct
  # reading are excluded so a decoy can't also be right.
  def sibling_pool(correct)
    siblings = deck.cards.where.not(id: next_card.id)
    pairs = siblings.joins(:item).pluck("items.text", "items.reading")
    pairs.select { |_, reading| reading.present? && reading != correct }
  end

  def multiple_choice_answers
    distractors = next_card.distractors.sample(4)
    distractors += category_distractors(distractors) if category_pool?
    [*distractors, next_card.back].shuffle
  end

  def category_pool?
    deck.distractor_pool == "category"
  end

  def category_distractors(chosen)
    excluded = chosen + [next_card.back]
    same = pick(sibling_backs(next_card.category), excluded, 4 - chosen.length)
    same + pick(sibling_backs, excluded + same, 4 - chosen.length - same.length)
  end

  def pick(backs, excluded, count)
    (backs - excluded).uniq.sample(count)
  end

  def sibling_backs(category = nil)
    scope = category ? deck.cards_in_category(category) : deck.cards
    scope.where.not(id: next_card.id).map(&:back)
  end

  def fuzzy_answers
    deck.cards.map(&:back).uniq
  end
end
