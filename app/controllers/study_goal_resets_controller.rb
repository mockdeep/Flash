# frozen_string_literal: true

# Once every deck has met its goal for the day, starts a new batch on all of
# them and heads back to the first deck.
class StudyGoalResetsController < ApplicationController
  def create
    StudyDay
      .where(deck: current_user.decks, studied_on: Date.current)
      .find_each(&:start_batch!)
    deck = current_user.next_unmet_deck
    redirect_to(deck ? deck_study_path(deck) : decks_path)
  end
end
