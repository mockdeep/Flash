# frozen_string_literal: true

module Views
  module Catalog
    class Show < Views::Base
      attr_accessor :deck

      def initialize(deck:)
        super()
        self.deck = deck
      end

      def view_template
        div(class: "catalog-show-container") do
          render_header
          render_card_preview
          render(Components::DeckTexts.new(deck:))
          render_action
        end
      end

      private

      def render_header
        div(class: "catalog-show-header") do
          render_back_link
          h1(class: "catalog-show-title") do
            plain(deck.name)
            music_badge if deck.music?
            translation(deck.name_translation)
          end
          render_meta
        end
      end

      def render_back_link
        link_to("Back to Catalog", catalog_index_path, class: "back-link")
      end

      def render_meta
        div(class: "catalog-show-meta") do
          span { "#{deck.cards_count} cards" }
          span(class: "catalog-meta-separator") { "|" }
          span do
            plain("by #{deck.user.username}")
            supporter_badge if deck.user.supporter?
          end
        end
      end

      def render_card_preview
        render(Components::CardPreview.new(deck:))
      end

      def render_action
        if member?
          div(class: "catalog-show-actions") { render_copy_button }
        else
          render_demo_actions
        end
      end

      def render_demo_actions
        div(class: "catalog-show-actions") do
          render_try_button
          render_login_link
        end
        p(class: "catalog-show-note") do
          "Demos include the first #{Deck::GUEST_CARD_LIMIT} cards."
        end
      end

      def member? = current_user.logged_in? && !current_user.guest?

      def render_try_button
        form_with(url: try_catalog_path(deck), method: :post) do |form|
          timezone_field(form)
          form.button("Try This Deck", class: button_class(:primary))
        end
      end

      def render_copy_button
        button_to(
          "Add to My Decks",
          copy_catalog_path(deck),
          method: :post,
          class: button_class(:primary),
        )
      end

      def render_login_link
        link_to(
          "Log in to Add Deck",
          new_session_path,
          class: button_class(:ghost),
        )
      end
    end
  end
end
