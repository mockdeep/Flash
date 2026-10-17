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
          render(Components::DeckTexts.new(deck:))
          render_action
        end
      end

      private

      def render_header
        div(class: "catalog-show-header") do
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
          span { "#{deck.cards_count} cards" }
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
            render_member_action
          else
            render_try_button
          end
        end
      end

      def render_member_action
        own_deck = current_user.deck_for(deck)
        own_deck ? render_study_link(own_deck) : render_copy_button
      end

      def render_study_link(own_deck)
        link_to(
          "Study (in your decks)",
          deck_study_path(own_deck),
          class: button_class(:primary),
        )
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
        form_with(
          url: try_shared_deck_path(deck.share_token),
          method: :post,
        ) do |form|
          timezone_field(form)
          form.button("Try This Deck", class: button_class(:primary))
        end
      end
    end
  end
end
