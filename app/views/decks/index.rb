# frozen_string_literal: true

module Views
  module Decks
    class Index < Views::Base
      attr_accessor :decks

      def initialize(decks:)
        super()
        self.decks = decks
      end

      def view_template
        h1 { "Your Decks" }

        link_to("Create New Deck", new_deck_path)

        if decks.empty?
          p { "You have no decks yet." }
          return
        end

        ul do
          decks.each do |deck|
            li do
              link_to(deck.name, deck_study_path(deck))
            end
          end
        end
      end
    end
  end
end
