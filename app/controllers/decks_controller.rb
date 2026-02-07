# frozen_string_literal: true

class DecksController < ApplicationController
  def index
    render(Views::Decks::Index.new(decks: current_user.decks))
  end

  def show
    deck = current_user.decks.find(params[:id])

    render(Views::Decks::Show.new(deck:))
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
      flash.now[:error] = error_messages(result.record)
      render(Views::Decks::New.new(deck: result.record))
    end
  end

  private

  def error_messages(record)
    record.errors.full_messages.join(", ")
  end

  def deck_params
    params.expect(deck: [:name, :cards_csv]).to_h.symbolize_keys
  end
end
