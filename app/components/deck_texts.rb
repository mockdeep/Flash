# frozen_string_literal: true

module Components
  # The texts a deck's word_list was built from, beside its card preview.
  # A text its license keeps from sharing is still listed, so a learner
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
        h2(class: "catalog-preview-title") { "Texts" }
        render_table
        render_note if deck.shares_texts?
      end
    end

    private

    def render_table
      texts = Table.new(headings: HEADINGS, rows: deck.finished_snippets)

      render(texts) do |table, snippet|
        table.cell { snippet.title }
        table.cell { snippet.author }
        table.cell { render_license(snippet) }
      end
    end

    def render_license(snippet)
      return render(SnippetLicense.new(snippet:)) if snippet.shareable?

      span(class: "catalog-preview-empty") { "Not included — words only" }
    end

    def render_note
      p(class: "catalog-preview-more") do
        "Read the included texts beside the cards, on the deck's Read tab"
      end
    end
  end
end
