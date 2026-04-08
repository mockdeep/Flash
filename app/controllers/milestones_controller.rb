# frozen_string_literal: true

class MilestonesController < ApplicationController
  def update
    deck = current_user.decks.find(params[:deck_id])
    deck.update!(study_goal: params[:study_goal])
    redirect_to(deck_study_path(deck))
  end
end
