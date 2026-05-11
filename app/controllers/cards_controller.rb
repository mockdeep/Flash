# frozen_string_literal: true

class CardsController < ApplicationController
  def update
    deck = current_user.decks.find(params.expect(:deck_id))
    card = deck.cards.find(params.expect(:id))

    if card.update(card_params)
      render(turbo_stream: success_streams(card:, deck:))
    else
      render(
        Views::Cards::EditForm.new(deck:, card:),
        status: :unprocessable_content,
      )
    end
  end

  private

  def card_params
    params.expect(card: [:front, :back, :category])
  end

  def success_streams(card:, deck:)
    [
      replace_question(card),
      replace_answer(card),
      replace_edit_form(card:, deck:),
    ]
  end

  def replace_question(card)
    turbo_stream.replace(
      "card-question",
      helpers.content_tag(
        :h2,
        card.front,
        class: "card-front",
        id: "card-question",
      ),
    )
  end

  def replace_answer(card)
    turbo_stream.replace(
      "correct-answer-text",
      helpers.content_tag(
        :span,
        card.back,
        class: "answer-text",
        id: "correct-answer-text",
      ),
    )
  end

  def replace_edit_form(card:, deck:)
    turbo_stream.replace(
      "card_edit_form",
      render_to_string(
        Views::Cards::EditForm.new(deck:, card:),
      ),
    )
  end
end
