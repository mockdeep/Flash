# frozen_string_literal: true

class DecksController < ApplicationController
  def index
    pending_counts = current_user.pending_suggestion_counts_per_deck
    render(
      Views::Decks::Index.new(
        decks: filtered_decks(pending_counts),
        pending_counts:,
        filter_pending: filter_pending?,
      ),
    )
  end

  def show
    deck = current_user.decks.find(params.expect(:id))

    render(Views::Decks::Show.new(deck:))
  end

  def new
    deck = BasicDeck.new(data_set: BasicDataSet.new)
    render(Views::Decks::New.new(deck:))
  end

  def create
    return language_missing_error if language_missing?

    result = create_action.call(**create_params, user: current_user)
    result.success? ? deck_created : deck_create_failed(result.record)
  end

  def destroy
    current_user.decks.find(params.expect(:id)).destroy!
    flash[:success] = t(".success")
    redirect_to(decks_path)
  end

  private

  def filtered_decks(pending_counts)
    decks = current_user.decks.ordered
    filter_pending? ? decks.where(id: pending_counts.keys) : decks
  end

  def filter_pending?
    params[:filter] == "pending_suggestions"
  end

  def create_action
    deck_params[:deck_type] == "music" ? Decks::CreateMusic : Decks::Create
  end

  def create_params
    deck_params.except(:deck_type)
  end

  # The language select is disabled unless the Language deck type is chosen,
  # so a blank value only arrives when browser validation is bypassed.
  def language_missing?
    deck_params[:deck_type] == "language" && deck_params[:language].blank?
  end

  def language_missing_error
    deck = BasicDeck.new(data_set: BasicDataSet.new(name: deck_params[:name]))
    deck.errors.add(:base, "Please select a language")
    deck_create_failed(deck)
  end

  def deck_created
    flash[:success] = t(".success")
    redirect_to(decks_path)
  end

  def deck_create_failed(record)
    flash.now[:error] = error_messages(record)
    render(Views::Decks::New.new(deck: record))
  end

  def error_messages(record)
    record.errors.full_messages.join(", ")
  end

  def deck_params
    params.expect(deck: [:name, :cards_csv, :deck_type, :ordered, :language])
      .to_h.symbolize_keys
  end
end
