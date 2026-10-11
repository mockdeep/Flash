# frozen_string_literal: true

# A word looked up on the Read tab: its meaning shows in a popover, and the
# lookup counts as a miss so study brings the word back.
class LookupsController < ApplicationController
  def create
    deck = ReadingDeck.where(user: current_user).find(params.expect(:deck_id))
    sense = deck.word_list.senses.find(params.expect(:sense_id))
    SkillScore.find_or_initialize_by(
      user: current_user, sense:, skill: deck.skill,
    ).record_miss!

    head(:no_content)
  end
end
