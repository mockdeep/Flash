# frozen_string_literal: true

module Components
  # The Read tab: a deck's source, then its snippets word by word, laid out
  # as written. The deck's level takes the help away: readings over each
  # word at level 1 in a language that has them, gaps between words up to
  # level 2, plain text after that. Clicking a word shows its reading and
  # gloss in a popover, and resets its streak so study brings it back.
  class SnippetReading < Components::Base
    READINGS_LEVEL = 1
    GAPS_LEVEL = 2

    attr_accessor :snippets, :deck

    def initialize(snippets:, deck:)
      super()
      self.snippets = snippets
      self.deck = deck
    end

    def view_template
      div(class: classes, data:) do
        render_source(deck.source)
        snippets.each { |snippet| render_snippet(snippet) }
      end
    end

    private

    def render_source(source)
      h2 { source.title }
      author = source.author
      p(class: "reading-snippets__author") { author } if author.present?
      p(class: "reading-snippets__credit") do
        render(SourceCredit.new(source:))
      end
    end

    def render_snippet(snippet)
      section(class: "reading-snippet") do
        h3 { snippet.heading } if snippet.heading.present?
        snippet.paragraphs.each { |paragraph| render_paragraph(paragraph) }
      end
    end

    # The popovers follow the paragraph rather than sit in it, so its text
    # stays just the words; each still opens beside its own word.
    def render_paragraph(paragraph)
      lookups = []
      p { paragraph.tokens.each { |token| render_token(token, lookups) } }
      lookups.each { |id, sense| render_lookup(id, sense) }
    end

    def render_token(token, lookups)
      sense = senses[token["sense_id"]]
      return plain(token["text"]) unless sense

      # While gapped, the CSS keeps a word on one line, which also stops
      # Chrome breaking between words written without spaces, so mark the
      # place to break: before the word, so punctuation stays at the end of
      # the line it closes.
      wbr unless language.spaces
      id = "lookup-#{lookup_count}"
      render_word(token["text"], sense, id)
      lookups << [id, sense]
    end

    def render_word(text, sense, id)
      button(**word_attributes(id, sense)) do
        ruby do
          plain(text)
          rt { sense.entry.reading } if readings?
        end
      end
    end

    def render_lookup(id, sense)
      div(id:, popover: true, class: "reading-snippet__lookup") do
        if language.readings
          div(class: "reading-snippet__lookup-reading") { sense.entry.reading }
        end
        plain(sense.gloss)
      end
    end

    def word_attributes(id, sense)
      {
        type: "button",
        class: "reading-snippet__word",
        popovertarget: id,
        data: { action: "lookup#record", lookup_sense_id_param: sense.id },
      }
    end

    def lookup_count
      @lookup_count = (@lookup_count || 0) + 1
    end

    def senses
      @senses ||= Sense.where(id: sense_ids).index_by(&:id)
    end

    def sense_ids
      snippets.flat_map(&:sentences).flat_map(&:tokens).pluck("sense_id")
    end

    def data
      { controller: "lookup", lookup_url_value: deck_lookups_path(deck) }
    end

    def classes
      [
        "reading-snippets",
        ("reading-snippets--readings" if readings?),
        ("reading-snippets--gaps" if gaps?),
        ("reading-snippets--spaced" if language.spaces),
      ]
    end

    def language = deck.source.language
    def readings? = language.readings && deck.level <= READINGS_LEVEL
    def gaps? = deck.level <= GAPS_LEVEL
  end
end
