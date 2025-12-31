# frozen_string_literal: true

class DecksController < ApplicationController
  def index
    render(Views::Decks::Index.new(decks: current_user.decks))
  end

  def new
    render(Views::Decks::New.new(deck: Deck.new))
  end

  def create
    result = Decks::Create.call(**deck_params, user: current_user)
    if result.success?
      flash[:success] = "Deck created successfully"
      redirect_to(decks_path)
    else
      flash.now[:error] = "There was a problem creating the deck"
      render(Views::Decks::New.new(deck: result.record))
    end
  end

  private

  def deck_params
    params.expect(deck: [:name, :cards_csv]).to_h.symbolize_keys
  end
end
