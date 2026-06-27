# frozen_string_literal: true

module Components
  class CardPreview < Components::Base
    PREVIEW_LIMIT = 5

    attr_reader :deck

    def initialize(deck:)
      super()
      @deck = deck
    end

    def view_template
      div(class: "card card--striped catalog-preview") do
        h2(class: "catalog-preview-title") { "Card Preview" }

        if preview_cards.empty?
          render_empty
        else
          render_table
          render_more_count
        end
      end
    end

    private

    def preview_cards
      @preview_cards ||=
        deck.cards.ordered
          .includes(item: { pairings: :paired_item })
          .limit(PREVIEW_LIMIT)
    end

    def render_empty
      p(class: "catalog-preview-empty") { t(".empty") }
    end

    def render_table
      table(class: "catalog-preview-table") do
        thead { render_header_row }
        tbody { preview_cards.each { |card| render_body_row(card) } }
      end
    end

    def render_header_row
      tr do
        th { "Front" }
        th { "Back" }
      end
    end

    def render_body_row(card)
      tr do
        td { card.front }
        td { card.back }
      end
    end

    def render_more_count
      return if deck.cards.count <= PREVIEW_LIMIT

      p(class: "catalog-preview-more") do
        "and #{deck.cards.count - PREVIEW_LIMIT} more cards..."
      end
    end
  end
end
