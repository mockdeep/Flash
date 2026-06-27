# frozen_string_literal: true

class CardsController < ApplicationController
  include ProjectsCards

  def update
    deck = current_user.decks.find(params.expect(:deck_id))
    card = deck.cards.find(params.expect(:id))

    if save_card(card)
      update_succeeded(deck, card)
    else
      update_failed(deck, card)
    end
  end

  def destroy
    deck = current_user.decks.find(params.expect(:deck_id))
    destroy_card(deck.cards.find(params.expect(:id)))

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
      card: [:front, :back, :category, :reading, :example_front, :example_back],
    )
  end

  def suggest_to_catalog?
    params.dig(:card, :suggest_to_catalog).to_s == "1"
  end

  def create_catalog_suggestion(card)
    return unless card.suggestable_to_catalog?

    content = CardContent.new(card)
    CardSuggestion.create!(
      card: card.source_card,
      user: current_user,
      front: content.front,
      back: content.back,
      category: content.category,
    )
  end

  def success_streams(card:, deck:)
    content = CardContent.new(card)
    [
      replace_question(content),
      replace_answer(content),
      *replace_components(content),
      replace_edit_form(card:, deck:),
    ]
  end

  def replace_question(content)
    turbo_stream.replace(
      "card-question",
      helpers.content_tag(
        :h2,
        content.front,
        class: "card-front",
        id: "card-question",
      ),
    )
  end

  def replace_answer(content)
    turbo_stream.replace(
      "correct-answer-text",
      helpers.content_tag(
        :span,
        content.back,
        class: "answer-text",
        id: "correct-answer-text",
      ),
    )
  end

  def replace_components(content)
    [
      Components::CardReading.new(reading: content.reading),
      Components::StudyExample.new(content:),
    ].map do |component|
      turbo_stream.replace(
        component.class::WRAPPER_ID,
        render_to_string(component),
      )
    end
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
