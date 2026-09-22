# frozen_string_literal: true

module Components
  class CardPreview < Components::Base
    PREVIEW_LIMIT = 5
    HEADINGS = ["Front", "Back"].freeze

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
      @preview_cards ||= deck.cards_in_order(limit: PREVIEW_LIMIT)
    end

    def render_empty
      p(class: "catalog-preview-empty") { t(".empty") }
    end

    def render_table
      preview = Table.new(headings: HEADINGS, rows: preview_cards)

      render(preview) do |table, card|
        table.cell { card.front }
        table.cell { card.back }
      end
    end

    def render_more_count
      more = deck.cards_count - PREVIEW_LIMIT
      return unless more.positive?

      p(class: "catalog-preview-more") { "and #{more} more cards..." }
    end
  end
end
