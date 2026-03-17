# frozen_string_literal: true

class CatalogController < ApplicationController
  skip_before_action(:authenticate_user, only: [:index, :show])

  def index
    decks = Deck.publicly_visible.ordered
    render(Views::Catalog::Index.new(decks:))
  end

  def show
    render(Views::Catalog::Show.new(deck: public_deck))
  end

  def copy
    result = Catalog::CopyDeck.call(user: current_user, deck: public_deck)

    if result.success?
      flash[:success] = "Deck copied successfully"
      redirect_to(decks_path)
    else
      flash.now[:error] = error_messages(result.record)
      render(Views::Catalog::Show.new(deck: public_deck))
    end
  end

  private

  def public_deck
    Deck.publicly_visible.find(params[:id])
  end

  def error_messages(record)
    record.errors.full_messages.join(", ")
  end
end
