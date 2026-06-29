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
    deck = TextDeck.new(data_set: DataSet.new)
    render(Views::Decks::New.new(deck:))
  end

  def create
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
    params.expect(deck: [:name, :cards_csv, :deck_type, :ordered])
      .to_h.symbolize_keys
  end
end
