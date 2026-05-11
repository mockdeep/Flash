# frozen_string_literal: true

class DemoController < ApplicationController
  skip_before_action(:authenticate_user)

  def show
    @decks = Deck.demo_visible
    render(Views::Demo::Show.new(decks: @decks))
  end

  def create
    result = start_demo
    save_demo_session(result)
    redirect_to(deck_study_path(result.deck))
  end

  private

  def start_demo
    deck = Deck.demo_visible.find(params.expect(:deck_id))
    Demo::CreateGuestUser.call(deck:)
  end

  def save_demo_session(result)
    log_in(result.user)
    session[:demo_user_id] = result.user.id
    session[:demo] = true
  end
end
