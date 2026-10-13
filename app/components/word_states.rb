# frozen_string_literal: true

module Components
  # How an answered card's words now stand, so the Read tab beside the study
  # frame can mark them without a reload.
  class WordStates < Components::Base
    attr_accessor :deck, :card

    def initialize(deck:, card:)
      super()
      self.deck = deck
      self.card = card
    end

    def view_template
      states = card.sense_ids.index_with { state(it) }.to_json
      data = { controller: "word-states", word_states_states_value: states }
      div(hidden: true, data:)
    end

    private

    def state(sense_id)
      scores.fetch(sense_id) { SkillScore.new }.state(deck.level)
    end

    def scores
      @scores ||= deck.user.skill_scores
        .where(skill: deck.skill, sense_id: card.sense_ids)
        .index_by(&:sense_id)
    end
  end
end
