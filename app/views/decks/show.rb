# frozen_string_literal: true

module Views
  module Decks
    class Show < Views::Base
      attr_accessor :deck

      def initialize(deck:)
        super()
        self.deck = deck
      end

      def view_template
        link_to("Back to Decks", decks_path)

        h1 { deck.name }

        if deck.cards.empty?
          p { "This deck has no cards yet." }
        else
          link_to("Study Deck", deck_study_path(deck))
          table do
            thead do
              tr do
                th { "Front" }
                th { "Back" }
                th { "Category" }
              end
            end
            tbody do
              deck.cards.ordered.each do |card|
                tr do
                  td { card.front }
                  td { card.back }
                  td { card.category }
                end
              end
            end
          end
        end
      end
    end
  end
end
