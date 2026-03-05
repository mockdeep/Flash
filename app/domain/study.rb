# frozen_string_literal: true

class Study
  ACTIVE_CARD_THRESHOLD = 20
  CARD_DONE_THRESHOLD = 1
  Result =
    Data.define(
      :correct,
      :correct_answer,
      :question,
      :selected_answer,
      :possible_answers,
      :card_completed,
    ) do
      def correct? = correct
      def card_completed? = card_completed
    end

  attr_accessor :deck, :next_card, :active_card_threshold

  def initialize(deck:, active_card_threshold: ACTIVE_CARD_THRESHOLD)
    self.active_card_threshold = active_card_threshold
    self.deck = deck
    self.next_card = pick_next_card
  end

  def pick_next_card
    new_cards_count = active_card_threshold - deck.cards.active.count
    deck.cards.pending.ordered.limit(new_cards_count)
      .update_all(status: "active")

    deck.cards.active.sample
  end

  def complete?
    next_card.nil?
  end

  def possible_answers
    return [] if next_card.nil?

    wrong_answers = next_card.wrong_answers.first(4)
    other_cards = deck.cards.distinct(:back).where.not(back: next_card.back)

    wrong_answers += other_cards.where(category: next_card.category)
      .where.not(back: wrong_answers)
      .sample(4 - wrong_answers.length)
      .pluck(:back)

    wrong_answers += other_cards
      .where.not(back: wrong_answers)
      .sample(4 - wrong_answers.length)
      .pluck(:back)

    [*wrong_answers, next_card.back].shuffle
  end

  def answer_card(card_id:, answer:, possible_answers: [])
    card = deck.cards.find(card_id)
    card.view_count += 1
    if card.back == answer
      card.correct_count += 1
      card.correct_streak += 1
      card_completed = card.correct_streak >= CARD_DONE_THRESHOLD
      card.status = "done" if card_completed
      card.save!
      Result.new(
        correct: true,
        correct_answer: card.back,
        question: card.front,
        selected_answer: answer,
        possible_answers:,
        card_completed:,
      )
    else
      card.wrong_answers.unshift(answer).uniq!
      card.correct_streak = 0
      card.save!
      Result.new(
        correct: false,
        correct_answer: card.back,
        question: card.front,
        selected_answer: answer,
        possible_answers:,
        card_completed: false,
      )
    end
  end
end
