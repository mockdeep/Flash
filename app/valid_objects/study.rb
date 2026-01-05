# frozen_string_literal: true

class Study
  attr_accessor :deck, :next_card

  ACTIVE_CARD_THRESHOLD = 20
  CARD_DONE_THRESHOLD = 3

  def initialize(deck:)
    self.deck = deck
    self.next_card = pick_next_card
  end

  def pick_next_card
    new_cards_count = ACTIVE_CARD_THRESHOLD - deck.cards.active.count
    deck.cards.pending.ordered.limit(new_cards_count)
      .update_all(status: "active")

    deck.cards.active.sample
  end

  def possible_answers
    wrong_answers = next_card.wrong_answers.first(4)
    other_cards = deck.cards.distinct(:back).where.not(back: next_card.back)

    wrong_answers += other_cards.where(category: next_card.category)
      .sample(4 - wrong_answers.length)
      .pluck(:back)

    wrong_answers += other_cards
      .where.not(back: wrong_answers)
      .sample(4 - wrong_answers.length)
      .pluck(:back)

    [*wrong_answers, next_card.back].shuffle
  end

  def answer_card(card_id:, answer:)
    card = deck.cards.find(card_id)
    card.view_count += 1
    if card.back == answer
      card.correct_count += 1
      card.correct_streak += 1
      card.status = "done" if card.correct_streak >= CARD_DONE_THRESHOLD
      card.save!
      Result.new(correct: true, correct_answer: card.back, question: card.front)
    else
      card.wrong_answers.unshift(answer).uniq!
      card.correct_streak = 0
      card.save!
      Result.new(
        correct: false,
        correct_answer: card.back,
        question: card.front,
      )
    end
  end

  class Result
    attr_accessor :correct, :correct_answer, :question

    def initialize(correct:, correct_answer:, question:)
      self.correct = correct
      self.correct_answer = correct_answer
      self.question = question
    end

    def correct?
      correct
    end
  end
end
