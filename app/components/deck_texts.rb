# frozen_string_literal: true

module Components
  # The source a deck's word_list was built from, beside its card preview.
  # A source its license keeps from sharing is still listed, so a learner
  # can see where the words came from, but marked as not included.
  class DeckTexts < Components::Base
    HEADINGS = ["Title", "Author", "License"].freeze

    attr_accessor :deck

    def initialize(deck:)
      super()
      self.deck = deck
    end

    def render? = deck.finished_snippets.any?

    def view_template
      div(class: "card card--striped catalog-preview") do
        h2(class: "catalog-preview-title") { "Source" }
        render_table
        render_note if deck.shares_texts?
      end
    end

    private

    def render_table
      texts = Table.new(headings: HEADINGS, rows: [deck.source])

      render(texts) do |table, source|
        table.cell { source.title }
        table.cell { source.author }
        table.cell { render_license(source) }
      end
    end

    def render_license(source)
      return render(SourceLicense.new(source:)) if source.shareable?

      span(class: "catalog-preview-empty") { "Not included — words only" }
    end

    def render_note
      p(class: "catalog-preview-more") do
        "Read it beside the cards, on the deck's Read tab"
      end
    end
  end
end
