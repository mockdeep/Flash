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
          render_action
        end
      end

      private

      def render_header
        div(class: "catalog-show-header") do
          render_back_link
          h1(class: "catalog-show-title") { deck.name }
          render_meta
        end
      end

      def render_back_link
        link_to("Back to Catalog", catalog_index_path, class: "back-link")
      end

      def render_meta
        div(class: "catalog-show-meta") do
          span { "#{deck.cards.count} cards" }
          span(class: "catalog-meta-separator") { "|" }
          span do
            plain("by #{deck.user.username}")
            supporter_badge if deck.user.supporter?
          end
        end
      end

      def render_card_preview
        preview_cards = deck.cards.ordered.limit(5)

        div(class: "card card--striped catalog-preview") do
          h2(class: "catalog-preview-title") do
            "Card Preview"
          end

          if preview_cards.empty?
            render_preview_empty
          else
            render_preview_table(preview_cards)
            render_more_count
          end
        end
      end

      def render_preview_empty
        p(class: "catalog-preview-empty") do
          "This deck has no cards yet."
        end
      end

      def render_preview_table(preview_cards)
        table(class: "catalog-preview-table") do
          thead do
            tr do
              th { "Front" }
              th { "Back" }
            end
          end
          tbody do
            preview_cards.each do |card|
              tr do
                td { card.front }
                td { card.back }
              end
            end
          end
        end
      end

      def render_more_count
        return if deck.cards.count <= 5

        p(class: "catalog-preview-more") do
          "and #{deck.cards.count - 5} more cards..."
        end
      end

      def render_action
        div(class: "catalog-show-actions") do
          if current_user.logged_in?
            render_copy_button
          else
            render_login_link
          end
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
