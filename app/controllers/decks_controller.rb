# frozen_string_literal: true

class DecksController < ApplicationController
  def index
    render(Views::Decks::Index.new(decks: current_user.decks.ordered))
  end

  def show
    deck = current_user.decks.find(params.expect(:id))

    render(Views::Decks::Show.new(deck:))
  end

  def new
    render(Views::Decks::New.new(deck: BasicDeck.new))
  end

  def create
    result = create_deck
    result.success? ? deck_created : deck_create_failed(result.record)
  end

  def destroy
    current_user.decks.find(params.expect(:id)).destroy!
    flash[:success] = t(".success")
    redirect_to(decks_path)
  end

  private

  # Each family's create action takes only the params its form section offers.
  # Language decks are not creatable: their content comes from the catalog,
  # and a freeform CSV upload is a Basic deck.
  def create_deck
    shared = { user: current_user, **deck_params.slice(:name, :cards_csv) }
    if deck_params[:deck_type] == "music"
      Decks::CreateMusic.call(**shared, **deck_params.slice(:ordered))
    else
      Decks::CreateBasic.call(**shared)
    end
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
