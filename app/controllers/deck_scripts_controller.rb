# frozen_string_literal: true

class DeckScriptsController < ApplicationController
  def update
    deck = current_user.decks.find(params.expect(:deck_id))
    deck.update!(script: params.expect(:script))
    redirect_to(deck_study_path(deck))
  end
end
