# frozen_string_literal: true

class Study
  ACTIVE_CARD_THRESHOLD = 20
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

  attr_accessor :deck, :next_card, :active_card_threshold

  def self.for(deck:, **)
    klass = deck.music? ? MusicStudy : self
    klass.new(deck:, **)
  end

  def initialize(deck:, active_card_threshold: ACTIVE_CARD_THRESHOLD)
    self.active_card_threshold = active_card_threshold
    self.deck = deck
    self.next_card = pick_next_card
  end

  def pick_next_card
    deck.cards.not_done(deck.level).ordered.limit(active_card_threshold).sample
  end

  def possible_answers
    return [] if next_card.nil?

    distractors = next_card.distractors.first(4)

    if deck.distractor_pool == "category"
      other_cards = deck.cards.distinct(:back).where.not(back: next_card.back)

      distractors += other_cards.where(category: next_card.category)
        .where.not(back: distractors)
        .sample(4 - distractors.length)
        .pluck(:back)

      distractors += other_cards
        .where.not(back: distractors)
        .sample(4 - distractors.length)
        .pluck(:back)
    end

    [*distractors, next_card.back].shuffle
  end

  def answer_card(card_id:, answer:, possible_answers: [])
    card = deck.cards.find(card_id)
    card.view_count += 1
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
        possible_answers:,
        card_completed:,
        level_completed:,
      )
    else
      card.distractors.unshift(answer).uniq!
      card.correct_streak = 0
      card.save!
      Result.new(
        card:,
        correct: false,
        correct_answer: card.back,
        question: card.front,
        selected_answer: answer,
        possible_answers:,
        card_completed: false,
        level_completed: false,
      )
    end
  end
end
