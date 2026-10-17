# frozen_string_literal: true

module Views
  module Catalog
    class Index < Views::Base
      attr_accessor :deck_sections

      def initialize(deck_sections:)
        super()
        self.deck_sections = deck_sections
      end

      def view_template
        div(class: "catalog-container") do
          render_header

          if deck_sections.empty?
            render_empty_state
          else
            render_deck_sections
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

      def render_deck_sections
        deck_sections.each do |deck_section|
          render(Components::DeckRail.new(deck_section:)) do
            deck_section.decks.ordered.each { |deck| render_rail_card(deck) }
          end
        end
      end

      def render_rail_card(deck)
        div(class: "rail-card") do
          div(class: "rail-type") { deck.type_label }
          render_rail_title(deck)
          render_rail_meta(deck)
          if member?
            render_owned_link(deck)
          else
            render_try_button(deck)
          end
        end
      end

      def render_rail_title(deck)
        h3(class: "rail-title") do
          link_to(deck.name, catalog_path(deck))
          music_badge if deck.music?
          texts_badge if deck.shares_texts?
          translation(deck.name_translation)
        end
      end

      def render_rail_meta(deck)
        div(class: "rail-meta") do
          span(class: "catalog-rail-owner") do
            plain("by #{deck.user.username}")
            supporter_badge if deck.user.supporter?
          end
          span(class: "catalog-rail-count") do
            pluralize(deck.cards_count, "card")
          end
        end
      end

      def render_owned_link(deck)
        own_deck = current_user.deck_for(deck)
        return unless own_deck

        link_to(
          "✓ In your decks",
          deck_study_path(own_deck),
          class: "catalog-rail-owned",
        )
      end

      def render_try_button(deck)
        url = try_catalog_path(deck)
        form_with(url:, class: "catalog-rail-try") do |form|
          timezone_field(form)
          form.button("Try This Deck", class: button_class(:primary, :compact))
        end
      end

      def member? = current_user.logged_in? && !current_user.guest?
    end
  end
end
