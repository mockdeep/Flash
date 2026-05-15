# frozen_string_literal: true

class MusicStudy < Study
  attr_accessor :next_window

  def initialize(deck:)
    super
    self.next_window = pick_window
  end

  def pick_next_card = nil

  def possible_answers = []

  def pick_window
    return [] if deck.cards.none?

    anchor = pick_anchor
    deck.ordered? ? ordered_window(anchor) : unordered_window(anchor)
  end

  def record_answer(params)
    permitted = params.expect(answer: [:answer, { card_ids: [] }])
    answer_window(**permitted.to_h.symbolize_keys)
  end

  def answer_window(card_ids:, answer:)
    cards = card_ids.map { |id| deck.cards.find(id) }
    cards.each { |c| c.view_count += 1 }
    expected = cards.map(&:back).join(",")

    if expected == answer
      record_correct(cards, answer)
    else
      cards.each(&:save!)
      build_result(cards, answer, correct: false, level_completed: false)
    end
  end

  private

  def pick_anchor
    deck.cards.not_done(deck.level).order(:correct_streak, :id).first ||
      deck.cards.ordered.first
  end

  def record_correct(cards, answer)
    cards.each do |card|
      card.correct_count += 1
      card.correct_streak += 1
    end
    cards.each(&:save!)
    level_completed = deck.cards.not_done(deck.level).none?
    deck.update!(level: deck.level + 1) if level_completed
    build_result(cards, answer, correct: true, level_completed:)
  end

  def ordered_window(anchor)
    cards = deck.cards.ordered.to_a
    max_start = [cards.length - deck.level, 0].max
    start_idx = [cards.index(anchor), max_start].min
    cards[start_idx, deck.level]
  end

  def unordered_window(anchor)
    others = deck.cards.where.not(id: anchor.id).to_a.sample(deck.level - 1)
    [anchor, *others]
  end

  def build_result(cards, answer, correct:, level_completed:)
    Result.new(
      card: cards.first,
      correct:,
      correct_answer: cards.map(&:back).join(","),
      question: cards.first.front,
      selected_answer: answer,
      possible_answers: [],
      card_completed: cards.first.done?,
      level_completed:,
    )
  end
end
