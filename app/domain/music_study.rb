# frozen_string_literal: true

class MusicStudy < Study
  attr_accessor :next_window

  def initialize(deck:, exclude_card_id: nil, card_id: nil)
    super
    self.next_window = pick_window
  end

  def pick_next_card(**) = nil

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
    cards = card_ids.map { |id| studied_cards.find(id) }
    expected = sequence(cards)

    if expected == answer
      record_correct(cards, answer)
    else
      cards.each(&:record_view!)
      build_result(cards, answer, correct: false, level_completed: false)
    end
  end

  private

  def studied_cards
    deck.cards
  end

  def sequence(cards)
    cards.map(&:back).join(",")
  end

  def pick_anchor
    studied_cards.not_done(deck.level).order(:correct_streak, :id).first ||
      studied_cards.ordered.first
  end

  def record_correct(cards, answer)
    cards.each(&:record_correct!)
    level_completed = deck.cards.not_done(deck.level).none?
    deck.update!(level: deck.level + 1) if level_completed
    build_result(cards, answer, correct: true, level_completed:)
  end

  def ordered_window(anchor)
    cards = studied_cards.ordered.to_a
    max_start = [cards.length - deck.level, 0].max
    start_idx = [cards.index(anchor), max_start].min
    cards[start_idx, deck.level]
  end

  def unordered_window(anchor)
    others = studied_cards.where.not(id: anchor.id).to_a.sample(deck.level - 1)
    [anchor, *others]
  end

  def build_result(cards, answer, correct:, level_completed:)
    Result.new(
      card: cards.first,
      correct:,
      correct_answer: sequence(cards),
      question: cards.first.front,
      selected_answer: answer,
      possible_answers: [],
      card_completed: cards.first.done?,
      level_completed:,
    )
  end
end
