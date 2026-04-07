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
        div(class: "decks-container") do
          div(class: "decks-header") do
            h1(class: "decks-title") { "Your Decks" }
            div(class: "decks-header-actions") do
              link_to("Browse Catalog", catalog_index_path, class: button_class(:ghost))
              link_to("+ Create New Deck", new_deck_path, class: button_class(:primary))
            end
          end

          if decks.empty?
            render_empty_state
          else
            render_decks_grid
          end
        end
      end

      private

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

      def render_decks_grid
        div(class: "decks-grid") do
          decks.each do |deck|
            render_deck_card(deck)
          end
        end
      end

      def render_deck_card(deck)
        div(class: "card card--striped deck-card") do
          div(class: "deck-card-header") do
            div do
              h3(class: "deck-card-title") { deck.name }
              render_stars(deck.level - 1)
            end
            div(class: "card-count") do
              span(class: "count-number") { deck.cards.count }
              span(class: "count-label") { "cards" }
            end
          end

          if deck.cards.any?
            render_deck_stats(deck)
          else
            div(class: "deck-empty-message") do
              "No cards yet"
            end
          end

          div(class: "deck-card-actions") do
            link_to("Study", deck_study_path(deck), class: button_class(:secondary, :compact))
            link_to("View Details", deck_path(deck), class: button_class(:ghost, :compact))
          end
        end
      end

      def render_deck_stats(deck)
        not_done_count = deck.cards.not_done(deck.level).count
        done_count = deck.cards.done(deck.level).count

        div(class: "deck-stats") do
          div(class: "stat-item stat-level") do
            div(class: "stat-value") { deck.level }
            div(class: "stat-label") { "Level" }
          end

          div(class: "stat-item stat-pending") do
            div(class: "stat-value") { not_done_count }
            div(class: "stat-label") { "Remaining" }
          end

          div(class: "stat-item stat-done") do
            div(class: "stat-value") { done_count }
            div(class: "stat-label") { "Done" }
          end
        end
      end

      def render_stars(completed_levels)
        div(class: "deck-card-stars") do
          3.times do |i|
            css = i < completed_levels ? "star star--filled" : "star star--empty"
            span(class: css) { "★" }
          end
        end
      end
    end
  end
end
