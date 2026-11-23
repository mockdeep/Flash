# frozen_string_literal: true

module Views
  module Decks
    class Index < Views::Base
      def view_template
        div(class: "decks-container") do
          render_header

          if current_user.decks.none?
            render_empty_state
          else
            render_deck_sections
          end
        end
      end

      private

      def render_header
        div(class: "decks-header") do
          h1(class: "decks-title") { "Your Decks" }
          div(class: "decks-header-actions") do
            link_to("Browse Catalog", catalog_index_path, class: button_class(:ghost))
            link_to("+ Create New Deck", new_deck_path, class: button_class(:primary))
          end
        end
      end

      def render_empty_state
        div(class: "empty-state") do
          div(class: "empty-state-icon") { "📚" }
          h2(class: "empty-state-title") { "No Decks Yet" }
          p(class: "empty-state-text") do
            "Create your first flashcard deck or browse the catalog to get started."
          end
          link_to("Create Your First Deck", new_deck_path, class: button_class(:primary))
        end
      end

      def render_deck_sections
        DeckSection.for(current_user.decks).each do |deck_section|
          render(Components::SectionRail.new(deck_section:))
        end
      end
    end
  end
end
