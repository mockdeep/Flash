# frozen_string_literal: true

module Views
  module Decks
    module Suggestions
      class Index < Views::Base
        attr_accessor :deck, :grouped_suggestions

        def initialize(deck:, grouped_suggestions:)
          super()
          self.deck = deck
          self.grouped_suggestions = grouped_suggestions
        end

        def view_template
          div(class: "catalog-show-container suggestions-page") do
            render_header
            render_body
          end
        end

        private

        def render_header
          div(class: "suggestions-header") do
            link_to("← Back to Deck", deck_path(deck), class: "back-link")
            h1(class: "suggestions-title") { "Suggestions for #{deck.name}" }
          end
        end

        def render_body
          grouped_suggestions.empty? ? render_empty : render_groups
        end

        def render_empty
          p(class: "suggestions-empty") { t("suggestions.index.empty") }
        end

        def render_groups
          div(class: "suggestion-groups") do
            grouped_suggestions.each do |card, suggestions|
              render_group(card, suggestions)
            end
          end
        end

        def render_group(card, suggestions)
          div(class: "card card--striped suggestion-group") do
            render_current_card(card)
            div(class: "suggestion-list") do
              suggestions.each { |suggestion| render_suggestion(suggestion) }
            end
          end
        end

        def render_current_card(card)
          content = CardContent.new(card)
          div(class: "suggestion-current") do
            h2(class: "suggestion-current-title") { "Current card" }
            render_field("Front", content.front)
            render_field("Back", content.back)
            render_field("Category", content.category)
          end
        end

        def render_suggestion(suggestion)
          div(class: "suggestion") do
            render_attribution(suggestion)
            render_proposed(suggestion)
            render_actions(suggestion)
          end
        end

        def render_attribution(suggestion)
          p(class: "suggestion-attribution") do
            "Suggested by #{suggestion.user.username}"
          end
        end

        def render_proposed(suggestion)
          div(class: "suggestion-proposed") do
            h3(class: "suggestion-proposed-title") { "Proposed" }
            render_field("Front", suggestion.front)
            render_field("Back", suggestion.back)
            render_field("Category", suggestion.category)
          end
        end

        def render_field(label_text, value)
          div(class: "suggestion-field") do
            span(class: "suggestion-field-label") { label_text }
            span(class: "suggestion-field-value") { value }
          end
        end

        def render_actions(suggestion)
          div(class: "suggestion-actions") do
            render_accept_button(suggestion)
            render_reject_button(suggestion)
          end
        end

        def render_accept_button(suggestion)
          button_to(
            "Accept",
            accept_deck_suggestion_path(deck, suggestion),
            method: :post,
            class: button_class(:primary, :compact),
            form: { data: { turbo_confirm: t("suggestions.accept.confirm") } },
          )
        end

        def render_reject_button(suggestion)
          button_to(
            "Reject",
            reject_deck_suggestion_path(deck, suggestion),
            method: :post,
            class: button_class(:ghost, :compact),
          )
        end
      end
    end
  end
end
