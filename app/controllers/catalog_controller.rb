# frozen_string_literal: true

class CatalogController < ApplicationController
  include DemoSession

  skip_before_action(:authenticate_user, only: [:index, :show, :try])

  def index
    decks = Deck.publicly_visible.ordered
    render(Views::Catalog::Index.new(decks:))
  end

  def show
    render(Views::Catalog::Show.new(deck: public_deck))
  end

  def copy
    result = Catalog::CopyDeck.call(user: current_user, deck: public_deck)
    result.success? ? deck_copied : deck_copy_failed(result.record)
  end

  def try
    result = Demo::CreateGuestUser.call(
      deck: public_deck,
      time_zone: params[:time_zone],
    )
    save_demo_session(result)
    redirect_to(deck_study_path(result.deck))
  end

  private

  def deck_copied
    flash[:success] = t(".success")
    redirect_to(decks_path)
  end

  def deck_copy_failed(record)
    flash.now[:error] = error_messages(record)
    render(Views::Catalog::Show.new(deck: public_deck))
  end

  def public_deck
    Deck.publicly_visible.find(params.expect(:id))
  end

  def error_messages(record)
    record.errors.full_messages.join(", ")
  end
end
