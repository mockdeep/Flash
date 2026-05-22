# frozen_string_literal: true

module Views
  module Decks
    class Show < Views::Base
      attr_accessor :deck

      def initialize(deck:)
        super()
        self.deck = deck
      end

      def view_template
        link_to("Back to Decks", decks_path)

        h1 { deck.name }

        if deck.cards.empty?
          p { "This deck has no cards yet." }
        else
          link_to("Study Deck", deck_study_path(deck))
        end

        render_share_section
        render(Components::CatalogToggleButton.new(deck:)) if admin_owner?
        render_replace_link if deck.is_a?(TextDeck)

        render_cards_table if deck.cards.any?
      end

      private

      def admin_owner?
        current_user.admin? && deck.user_id == current_user.id
      end

      def render_replace_link
        link_to(
          "Replace cards",
          new_deck_replacement_path(deck),
          class: button_class(:secondary, :compact),
        )
      end

      def render_cards_table
        table do
          thead do
            tr do
              th { "Front" }
              th { "Back" }
              th { "Category" }
            end
          end
          tbody do
            deck.cards.ordered.each do |card|
              tr do
                td { card.front }
                td { card.back }
                td { card.category }
              end
            end
          end
        end
      end

      def render_share_section
        div(class: "deck-share") do
          deck.shared? ? render_active_share : render_inactive_share
        end
      end

      def render_active_share
        render_share_url
        render_revoke_button
      end

      def render_inactive_share
        button_to(
          "Share Link",
          deck_share_path(deck),
          method: :post,
          class: button_class(:secondary, :compact),
        )
      end

      def render_share_url
        url = shared_deck_url(deck.share_token)
        div(
          class: "deck-share-url",
          data: { controller: "clipboard", clipboard_url_value: url },
        ) do
          input(
            type: "text",
            readonly: true,
            value: url,
            class: "deck-share-url-input",
          )
          button(
            type: "button",
            class: button_class(:secondary, :compact),
            data: {
              clipboard_target: "button",
              action: "click->clipboard#copy",
            },
          ) { "Copy" }
        end
      end

      def render_revoke_button
        confirm = "Revoke the share link? Anyone using it will lose access."
        button_to(
          "Revoke Link",
          deck_share_path(deck),
          method: :delete,
          class: button_class(:ghost, :compact),
          form: { data: { turbo_confirm: confirm } },
        )
      end
    end
  end
end
