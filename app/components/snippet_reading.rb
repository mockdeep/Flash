# frozen_string_literal: true

module Components
  # The Read tab: a deck's source, then its snippets word by word, laid out
  # as written, with gaps between words up to round 2. Each word is grey
  # until studied, green once done at the deck's round, and has its reading
  # over it while its streak is zero. Clicking a word shows its reading (or
  # a noun's article) and gloss in a popover, and resets its streak so study
  # brings it back. A word the segmenter skipped has no card, so its popover
  # says why and clicking it records nothing.
  class SnippetReading < Components::Base
    GAPS_ROUND = 2

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
      h2 { with_translation(source.title, source.title_translation) }
      author = source.author
      p(class: "reading-snippets__author") { author } if author.present?
      p(class: "reading-snippets__credit") do
        render(SourceCredit.new(source:))
      end
    end

    def render_snippet(snippet)
      section(class: "reading-snippet") do
        if snippet.heading.present?
          h3 { with_translation(snippet.heading, snippet.heading_translation) }
        end
        snippet.paragraphs.each { |paragraph| render_paragraph(paragraph) }
      end
    end

    # The popovers follow the paragraph rather than sit in it, so its text
    # stays just the words; each still opens beside its own word.
    def render_paragraph(paragraph)
      lookups = []
      p { paragraph.tokens.each { |token| render_token(token, lookups) } }
      lookups.each { render(it) }
    end

    def render_token(token, lookups)
      sense = senses[token["sense_id"]]
      skip = token["skip"]
      return plain(token["text"]) unless sense || skip

      # While gapped, the CSS keeps a word on one line, which also stops
      # Chrome breaking between words written without spaces, so mark the
      # place to break: before the word, so punctuation stays at the end of
      # the line it closes.
      wbr unless language.spaces
      id = "lookup-#{lookup_count}"
      render_word(token["text"], sense, id)
      lookups <<
        ReadingLookup.new(id:, text: token["text"], sense:, skip:, language:)
    end

    def render_word(text, sense, id)
      button(**word_attributes(id, sense)) do
        ruby do
          plain(text)
          rt { sense.entry.reading } if language.readings
        end
      end
    end

    # A skipped word has no card, so it has no state and records no lookup.
    def word_attributes(id, sense)
      attributes =
        { type: "button", class: "reading-snippet__word", popovertarget: id }
      return attributes unless sense

      attributes.merge(
        class: ["reading-snippet__word", word_state(sense)],
        data: { action: "lookup#record", lookup_sense_id_param: sense.id },
      )
    end

    def word_state(sense)
      state = scores.fetch(sense.id) { SkillScore.new }.state(deck.round)
      "reading-snippet__word--#{state}" if state
    end

    def lookup_count
      @lookup_count = (@lookup_count || 0) + 1
    end

    def senses
      @senses ||= Sense.where(id: sense_ids).index_by(&:id)
    end

    def scores
      @scores ||= deck.user.skill_scores
        .where(skill: deck.skill, sense_id: sense_ids).index_by(&:sense_id)
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
        ("reading-snippets--readings" if language.readings),
        ("reading-snippets--gaps" if gaps?),
        ("reading-snippets--spaced" if language.spaces),
      ]
    end

    def language = deck.source.language
    def gaps? = deck.round <= GAPS_ROUND
  end
end
