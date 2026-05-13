# frozen_string_literal: true

module Views
  module Shares
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
          render_action
        end
      end

      private

      def render_header
        div(class: "catalog-show-header") do
          h1(class: "catalog-show-title") do
            plain(deck.name)
            music_badge if deck.music?
          end
          render_meta
        end
      end

      def render_meta
        div(class: "catalog-show-meta") do
          span { "#{deck.cards.count} cards" }
          span(class: "catalog-meta-separator") { "|" }
          span do
            plain("shared by #{deck.user.username}")
            supporter_badge if deck.user.supporter?
          end
        end
      end

      def render_card_preview
        render(Components::CardPreview.new(deck:))
      end

      def render_action
        div(class: "catalog-show-actions") do
          if current_user.logged_in?
            render_copy_button
          else
            render_try_button
          end
        end
      end

      def render_copy_button
        button_to(
          "Add to My Decks",
          copy_shared_deck_path(deck.share_token),
          method: :post,
          class: button_class(:primary),
        )
      end

      def render_try_button
        button_to(
          "Try This Deck",
          try_shared_deck_path(deck.share_token),
          method: :post,
          class: button_class(:primary),
        )
      end
    end
  end
end
