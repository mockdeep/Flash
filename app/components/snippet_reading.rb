# frozen_string_literal: true

module Components
  # The Read tab: a deck's snippets, word by word. The deck's level takes
  # the help away: readings over each word at level 1, gaps between words
  # up to level 2, plain text after that.
  class SnippetReading < Components::Base
    READINGS_LEVEL = 1
    GAPS_LEVEL = 2

    attr_accessor :snippets, :level

    def initialize(snippets:, level:)
      super()
      self.snippets = snippets
      self.level = level
    end

    def view_template
      div(class: classes) do
        snippets.each { |snippet| render_snippet(snippet) }
      end
    end

    private

    def render_snippet(snippet)
      section(class: "reading-snippet") do
        h2 { snippet.title }
        author = snippet.author
        p(class: "reading-snippet__author") { author } if author.present?
        snippet.paragraphs.each do |sentences|
          p { sentences.each { |sentence| render_tokens(sentence.tokens) } }
        end
      end
    end

    def render_tokens(tokens)
      tokens.each do |token|
        sense = senses[token["sense_id"]]
        next plain(token["text"]) unless sense

        # While gapped, the CSS keeps a word on one line, which also stops
        # Chrome breaking between words, so mark the place to break: before
        # the word, so punctuation stays at the end of the line it closes.
        wbr
        ruby do
          plain(token["text"])
          rt { sense.entry.reading } if readings?
        end
      end
    end

    def senses
      @senses ||= Sense.where(id: sense_ids).index_by(&:id)
    end

    def sense_ids
      snippets.flat_map(&:sentences).flat_map(&:tokens).pluck("sense_id")
    end

    def classes
      [
        "reading-snippets",
        ("reading-snippets--readings" if readings?),
        ("reading-snippets--gaps" if gaps?),
      ]
    end

    def readings? = level <= READINGS_LEVEL
    def gaps? = level <= GAPS_LEVEL
  end
end
