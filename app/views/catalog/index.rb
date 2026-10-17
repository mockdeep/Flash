# frozen_string_literal: true

module Views
  module Catalog
    class Index < Views::Base
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
          h1(class: "catalog-title") { "Deck Catalog" }
          p(class: "catalog-subtitle") { subtitle }
        end
      end

      def subtitle
        if member?
          "Browse public decks and add them to your collection."
        else
          "Try any deck without an account. Demos include the first " \
            "#{Deck::GUEST_CARD_LIMIT} cards — no sign-up required."
        end
      end

      def render_empty_state
        div(class: "empty-state") do
          div(class: "empty-state-icon") { "📖" }
          h2(class: "empty-state-title") { "No Public Decks Yet" }
          p(class: "empty-state-text") do
            "Public decks will appear here when they become available."
          end
        end
      end

      def render_decks_grid
        div(class: "catalog-grid") do
          decks.each do |deck|
            render_deck_card(deck)
          end
        end
      end

      def render_deck_card(deck)
        div(class: "card card--striped catalog-card") do
          render_card_header(deck)
          render_card_meta(deck)
          render_card_actions(deck)
        end
      end

      def render_card_header(deck)
        div(class: "catalog-card-header") do
          render_card_title(deck)
          div(class: "card-count") do
            span(class: "count-number") { deck.cards_count }
            span(class: "count-label") { "cards" }
          end
        end
      end

      def render_card_title(deck)
        h3(class: "catalog-card-title") do
          plain(deck.name)
          music_badge if deck.music?
          texts_badge if deck.shares_texts?
          translation(deck.name_translation)
        end
      end

      def render_card_meta(deck)
        div(class: "catalog-card-meta") do
          span(class: "catalog-card-owner") do
            plain("by #{deck.user.username}")
            supporter_badge if deck.user.supporter?
          end
        end
      end

      def render_card_actions(deck)
        div(class: "catalog-card-actions") do
          link_to(
            "Preview",
            catalog_path(deck),
            class: button_class(:secondary, :compact),
          )
          render_try_button(deck) unless member?
        end
      end

      def render_try_button(deck)
        form_with(url: try_catalog_path(deck), method: :post) do |form|
          timezone_field(form)
          form.button(
            "Try This Deck",
            class: button_class(:primary, :compact),
          )
        end
      end

      def member? = current_user.logged_in? && !current_user.guest?
    end
  end
end
