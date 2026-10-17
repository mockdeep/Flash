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
        div(class: "catalog-show-container") do
          render_header
          render_actions
          render_share_url if deck.shared?
          render_cards
          render_delete_section
        end
      end

      private

      def empty?
        return @empty if defined?(@empty)

        @empty = deck.cards_count.zero?
      end

      def admin_owner?
        current_user.admin? && deck.user_id == current_user.id
      end

      def render_header
        div(class: "catalog-show-header") do
          link_to("Back to Decks", decks_path, class: "back-link")
          h1(class: "catalog-show-title") do
            plain(deck.name)
            music_badge if deck.music?
            translation(deck.name_translation)
          end
          render_meta
        end
      end

      def render_meta
        div(class: "catalog-show-meta") do
          meta_items.each_with_index do |item, index|
            span(class: "catalog-meta-separator") { "|" } if index.positive?
            span { item }
          end
        end
      end

      def meta_items
        [
          pluralize(deck.cards_count, "card"),
          "Round #{deck.round}",
          WordList::LANGUAGES[deck.language],
          deck.publicly_visible? ? "In catalog" : "Private",
        ].compact
      end

      def render_actions
        div(class: "deck-show-actions") do
          render_study_link unless empty?
          div(class: "deck-show-actions__secondary") do
            render_share_button unless deck.shared?
            render(Components::CatalogToggleButton.new(deck:)) if admin_owner?
            render_replace_link if deck.replaceable?
          end
        end
      end

      def render_study_link
        link_to(
          "Study Deck",
          deck_study_path(deck),
          class: button_class(:primary),
        )
      end

      def render_share_button
        button_to(
          "Share Link",
          deck_share_path(deck),
          method: :post,
          class: button_class(:secondary, :compact),
        )
      end

      def render_replace_link
        link_to(
          "Replace cards",
          new_deck_replacement_path(deck),
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
            aria_label: "Share link",
          )
          button(
            type: "button",
            class: button_class(:secondary, :compact),
            data: {
              clipboard_target: "button",
              action: "click->clipboard#copy",
            },
          ) { "Copy" }
          render_revoke_button
        end
      end

      def render_revoke_button
        button_to(
          "Revoke Link",
          deck_share_path(deck),
          method: :delete,
          class: button_class(:ghost, :compact),
          form: { data: { turbo_confirm: t("shares.destroy.confirm") } },
        )
      end

      def render_cards
        div(class: "card card--striped deck-show-cards") do
          h2(class: "catalog-preview-title") { "Cards" }

          if empty?
            p(class: "catalog-preview-empty") { "This deck has no cards yet." }
          else
            div(class: "deck-show-cards__scroll") { render_cards_table }
          end
        end
      end

      def render_cards_table
        readings = deck.readings?
        headings = ["Front", "Back", "Category"]
        headings.insert(1, "Reading") if readings
        cards_table = Components::Table.new(headings:, rows: table_cards)

        render(cards_table) do |table, card|
          table.cell { card.front }
          table.cell { card.reading } if readings
          table.cell { card.back }
          table.cell { card.category }
        end
      end

      def table_cards
        deck.cards_in_order
      end

      def render_delete_section
        div(class: "deck-show-danger") do
          div(class: "deck-show-danger__text") do
            strong { "Delete this deck" }
            p { "Removes the deck and all its study progress." }
          end
          render_delete_button
        end
      end

      def render_delete_button
        button_to(
          "Delete Deck",
          deck_path(deck),
          method: :delete,
          class: button_class(:danger, :compact),
          form: { data: { turbo_confirm: t("decks.destroy.confirm") } },
        )
      end
    end
  end
end
