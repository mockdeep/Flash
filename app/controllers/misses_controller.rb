# frozen_string_literal: true

# A Read-tab word recorded as a miss: a new word clicked for the first time,
# which counts as seen, or a done word sent back to study with Restudy,
# whose streak starts over.
class MissesController < ApplicationController
  def create
    deck = ReadingDeck.where(user: current_user).find(params.expect(:deck_id))
    sense = deck.word_list.senses.find(params.expect(:sense_id))
    SkillScore.find_or_initialize_by(
      user: current_user, sense:, skill: deck.skill,
    ).record_miss!

    head(:no_content)
  end
end
