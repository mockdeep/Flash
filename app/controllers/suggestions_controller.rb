# frozen_string_literal: true

class SuggestionsController < ApplicationController
  def index
    render(
      Views::Decks::Suggestions::Index.new(
        deck:,
        grouped_suggestions: pending_suggestions_by_card,
      ),
    )
  end

  def accept
    result = Catalog::AcceptSuggestion.call(suggestion:)
    result.success? ? accept_succeeded : accept_failed(result.record)
  end

  def reject
    suggestion.update!(state: "rejected")
    flash[:success] = t(".success")
    redirect_to(deck_suggestions_path(deck))
  end

  private

  def deck
    @deck ||= current_user.decks.find(params.expect(:deck_id))
  end

  def suggestion
    @suggestion ||= deck.incoming_suggestions.pending.find(params.expect(:id))
  end

  def pending_suggestions_by_card
    deck
      .incoming_suggestions
      .pending
      .order(:card_id, :created_at)
      .group_by(&:card)
  end

  def accept_succeeded
    flash[:success] = t(".success")
    redirect_to(deck_suggestions_path(deck))
  end

  def accept_failed(record)
    flash[:error] = record.errors.full_messages.join(", ")
    redirect_to(deck_suggestions_path(deck))
  end
end
