# frozen_string_literal: true

module Views
  module SectionDecks
    # The Basic or Music page: the user's own decks of that kind as a rail.
    class Rail < Views::Base
      attr_accessor :section, :sections

      def initialize(section:, sections:)
        super()
        self.section = section
        self.sections = sections
      end

      def view_template
        div(class: "decks-container") do
          render(Components::SectionSelector.new(sections:, current: section))
          link_to("+ Create New Deck", new_deck_path, class: create_class)
          render_decks
        end
      end

      private

      def create_class = button_class(:compact, :primary)

      def render_decks
        if section.decks.exists?
          render(Components::SectionRail.new(deck_section: section))
        else
          div(class: "empty-state") do
            p(class: "empty-state-text") { "No #{section.name} decks yet." }
          end
        end
      end
    end
  end
end
