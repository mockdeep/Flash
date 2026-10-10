# frozen_string_literal: true

# Once every deck has met its goal for the day, recalculates all of them (a
# new batch, with the goal worked out again) and heads back to the first deck.
class StudyGoalResetsController < ApplicationController
  def create
    StudyDay
      .where(deck: current_user.decks, studied_on: Date.current)
      .find_each(&:recalculate!)
    deck = current_user.next_unmet_deck
    redirect_to(deck ? deck_study_path(deck) : decks_path)
  end
end
