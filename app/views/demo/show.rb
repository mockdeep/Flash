# frozen_string_literal: true

module Views
  module Demo
    class Show < Views::Base
      attr_accessor :decks

      def initialize(decks:)
        super()
        self.decks = decks
      end

      def view_template
        div(class: "catalog-container") do
          render_header

          if decks.empty?
            render_empty_state
          else
            render_decks_grid
          end
        end
      end

      private

      def render_header
        div(class: "catalog-header") do
          h1(class: "catalog-title") { "Try Flash — No Account Needed" }
          p(class: "catalog-subtitle") do
            "Pick a deck below and start studying immediately. " \
              "Demos include the first 100 cards — no sign-up required."
          end
        end
      end

      def render_empty_state
        div(class: "empty-state") do
          h2(class: "empty-state-title") { "No demo decks available yet." }
          p(class: "empty-state-text") { "Check back soon!" }
        end
      end

      def render_decks_grid
        div(class: "catalog-grid") do
          decks.each { |deck| render_deck_card(deck) }
        end
      end

      def render_deck_card(deck)
        div(class: "card card--striped catalog-card") do
          render_deck_card_header(deck)
          render_deck_card_action(deck)
        end
      end

      def render_deck_card_header(deck)
        div(class: "catalog-card-header") do
          h3(class: "catalog-card-title") { deck.name }
          div(class: "card-count") do
            span(class: "count-number") { deck.cards.count }
            span(class: "count-label") { "cards" }
          end
        end
      end

      def render_deck_card_action(deck)
        form_with(url: demo_path(deck_id: deck.id), method: :post) do |form|
          timezone_field(form)
          form.button(
            "Try This Deck",
            class: button_class(:secondary, :compact),
          )
        end
      end
    end
  end
end
