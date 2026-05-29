# frozen_string_literal: true

class DemoController < ApplicationController
  include DemoSession

  skip_before_action(:authenticate_user)

  def show
    @decks = Deck.publicly_visible.ordered
    render(Views::Demo::Show.new(decks: @decks))
  end

  def create
    result = start_demo
    save_demo_session(result)
    redirect_to(deck_study_path(result.deck))
  end

  private

  def start_demo
    deck = Deck.publicly_visible.find(params.expect(:deck_id))
    Demo::CreateGuestUser.call(deck:, time_zone: params[:time_zone])
  end
end
