# frozen_string_literal: true

class DecksController < ApplicationController
  def index
    render(Views::Decks::Index.new(decks: current_user.decks.ordered))
  end

  def show
    deck = current_user.decks.find(params[:id])

    render(Views::Decks::Show.new(deck:))
  end

  def new
    render(Views::Decks::New.new(deck: TextDeck.new))
  end

  def create
    result = create_action.call(**create_params, user: current_user)
    result.success? ? deck_created : deck_create_failed(result.record)
  end

  private

  def create_action
    deck_params[:deck_type] == "music" ? Decks::CreateMusic : Decks::Create
  end

  def create_params
    deck_params.except(:deck_type)
  end

  def deck_created
    flash[:success] = "Deck created successfully"
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
    params.expect(deck: [:name, :cards_csv, :deck_type]).to_h.symbolize_keys
  end
end
