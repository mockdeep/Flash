# frozen_string_literal: true

class MilestonesController < ApplicationController
  def update
    deck = current_user.decks.find(params.expect(:deck_id))
    deck.update!(milestone_params)
    deck.study_days.today.recalculate! if recalculate?(deck)
    redirect_to(deck_study_path(deck))
  end

  private

  def milestone_params
    params.expect(deck: [:goal_mode, :study_goal, :target_level, :target_date])
  end

  def recalculate?(deck)
    params[:recalculate].present? ||
      deck.saved_change_to_goal_mode? ||
      deck.saved_change_to_target_level? ||
      deck.saved_change_to_target_date?
  end
end
