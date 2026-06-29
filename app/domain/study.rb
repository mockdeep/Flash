# frozen_string_literal: true

class Study
  ACTIVE_CARD_THRESHOLD = 20
  FUZZY_FIND_LEVEL = 3
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
    ) do
      def correct? = correct
      def card_completed? = card_completed
      def level_completed? = level_completed
    end

  attr_accessor :deck, :next_card

  def self.for(deck:, exclude_card_id: nil)
    klass = deck.music? ? MusicStudy : self
    klass.new(deck:, exclude_card_id:)
  end

  def initialize(deck:, exclude_card_id: nil)
    self.deck = deck
    self.next_card = pick_next_card(exclude_card_id:)
  end

  def active_card_threshold
    (2**(deck.level - 1)) * ACTIVE_CARD_THRESHOLD
  end

  def pick_next_card(exclude_card_id:)
    pool = deck.cards.not_done(deck.level).ordered.limit(active_card_threshold)
    pool.where.not(id: exclude_card_id).sample || pool.sample
  end

  def presentation_mode
    deck.level >= FUZZY_FIND_LEVEL ? :fuzzy_find : :multiple_choice
  end

  def record_answer(params)
    permitted =
      params.expect(answer: [:card_id, :answer, { possible_answers: [] }])
    answer_card(**permitted.to_h.symbolize_keys)
  end

  def possible_answers
    return [] if next_card.nil?

    case presentation_mode
    when :fuzzy_find then fuzzy_answers
    else multiple_choice_answers
    end
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
