# frozen_string_literal: true

class ReplacementsController < ApplicationController
  before_action(:ensure_text_deck)

  def new
    render(Views::Decks::Replacements::New.new(deck:))
  end

  def create
    result = Decks::Replace.call(
      deck:,
      cards_csv: replacement_params[:cards_csv],
    )
    if result.success?
      replacement_succeeded(result)
    else
      replacement_failed(result.record)
    end
  end

  private

  def deck
    @deck ||= current_user.decks.find(params.expect(:deck_id))
  end

  def replacement_succeeded(result)
    flash[:success] = t(".success", **result.summary.to_h)
    redirect_to(deck_path(deck))
  end

  def replacement_failed(record)
    flash.now[:error] = record.errors.full_messages.join(", ")
    render(Views::Decks::Replacements::New.new(deck: record))
  end

  def replacement_params
    params.expect(replacement: [:cards_csv]).to_h.symbolize_keys
  end

  def ensure_text_deck
    return if deck.instance_of?(TextDeck)

    flash[:error] = t("replacements.unsupported")
    redirect_to(deck_path(deck))
  end
end
