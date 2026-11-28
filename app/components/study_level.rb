# frozen_string_literal: true

module Components
  # The level a card is asked at, above it on the question and the answer
  # alike, and on a deck over a text how far into it study has reached.
  class StudyLevel < Components::Base
    attr_accessor :deck, :level

    def initialize(deck:, level:)
      super()
      self.deck = deck
      self.level = level
    end

    def view_template
      p(class: "study-level") { text }
    end

    private

    def text
      place = StudyPlace.new(deck).page
      label = "Level #{level}"
      place ? "#{label} · Studying up to page #{place}" : label
    end
  end
end
