# frozen_string_literal: true

class CardsController < ApplicationController
  def update
    deck = current_user.decks.find(params.expect(:deck_id))
    card = deck.cards.find(params.expect(:id))

    if card.update(card_params)
      update_succeeded(deck, card)
    else
      update_failed(deck, card)
    end
  end

  def destroy
    deck = current_user.decks.find(params.expect(:deck_id))
    deck.cards.find(params.expect(:id)).destroy!
    flash[:success] = t(".success")
    redirect_to(deck_study_path(deck))
  end

  private

  def update_succeeded(deck, card)
    create_catalog_suggestion(card) if suggest_to_catalog?
    render(turbo_stream: success_streams(card:, deck:))
  end

  def update_failed(deck, card)
    render(
      Views::Cards::EditForm.new(deck:, card:),
      status: :unprocessable_content,
    )
  end

  def card_params
    params.expect(
      card: [
        :front,
        :back,
        :category,
        :example_front,
        :example_back,
      ],
    )
  end

  def suggest_to_catalog?
    params.dig(:card, :suggest_to_catalog).to_s == "1"
  end

  def create_catalog_suggestion(card)
    return unless card.suggestable_to_catalog?

    CardSuggestion.create!(
      card: card.source_card,
      user: current_user,
      front: card.front,
      back: card.back,
      category: card.category,
    )
  end

  def success_streams(card:, deck:)
    [
      replace_question(card),
      replace_answer(card),
      replace_example(card),
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

  def replace_example(card)
    turbo_stream.replace(
      Components::StudyExample::WRAPPER_ID,
      render_to_string(Components::StudyExample.new(card:)),
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
