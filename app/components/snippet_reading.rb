# frozen_string_literal: true

module Components
  # The Read tab: a deck's source, then its snippets word by word, laid out
  # as written. Each word is grey until studied, green once done at the
  # deck's round, and has its reading over it while its streak is zero.
  # Mandarin is written in the deck's script. Clicking a word shows its
  # reading (or a noun's article) and gloss in a popover. The first click on
  # a new word records it as seen, and a done word's popover offers to
  # restudy it. A word the segmenter skipped has no card, so its popover
  # says why and clicking it records nothing.
  class SnippetReading < Components::Base
    attr_accessor :snippets, :deck

    def initialize(snippets:, deck:)
      super()
      self.snippets = snippets
      self.deck = deck
    end

    def view_template
      div(class: classes, data:) do
        render_source
        snippets.each { |snippet| render_snippet(snippet) }
      end
    end

    private

    def render_source
      source = deck.source
      render_line(source.title_paragraph, :h2)
      author = source.author_paragraph
      if author.text.present?
        render_line(author, :p, class: "reading-snippets__author")
      end
      p(class: "reading-snippets__credit") { render(SourceCredit.new(source:)) }
    end

    def render_snippet(snippet)
      section(class: "reading-snippet") do
        heading = snippet.heading_paragraph
        render_line(heading, :h3) if heading.text.present?
        snippet.paragraphs.each { |paragraph| render_line(paragraph, :p) }
      end
    end

    # The popovers follow the line rather than sit in it, so its text stays
    # just the words; each still opens beside the word clicked.
    def render_line(paragraph, tag, **)
      rendered = lookups.size
      tag(tag, **) { paragraph.tokens.each { render_token(it) } }
      lookups.values.drop(rendered).each { render(it) }
    end

    def render_token(token)
      sense = senses[token["sense_id"]]
      skip = token["skip"]
      return plain(token["text"]) unless sense || skip

      # While gapped, the CSS keeps a word on one line, which also stops
      # Chrome breaking between words written without spaces, so mark the
      # place to break: before the word, so punctuation stays at the end of
      # the line it closes.
      wbr unless language.spaces
      text = written(token, sense)
      state = word_state(sense)
      lookup = lookup_for(text:, sense:, skip:, state:)
      render_word(text, sense, lookup.id, state)
    end

    # A long text repeats its words, so every place that writes a word the
    # same way shares one popover, rendered after the first line using it.
    # The spelling counts, since a popover may show the word studied where
    # the text writes it otherwise (D. for Dona).
    def lookup_for(text:, sense:, skip:, state:)
      key = [sense&.id, skip, text.downcase]
      id = "lookup-#{lookups.size + 1}"
      lookups[key] ||= ReadingLookup.new(id:, text:, sense:, skip:, state:)
    end

    def lookups = @lookups ||= {}

    # A Mandarin word is written in the deck's script, whatever the text's.
    def written(token, sense)
      return token["text"] unless sense && language.traditional

      (sense.traditional if deck.traditional?) || sense.entry.headword
    end

    def render_word(text, sense, id, state)
      button(**word_attributes(id, sense, state)) do
        ruby do
          plain(text)
          rt { sense.entry.reading } if language.readings
        end
      end
    end

    # A skipped word has no card, so it has no state and records nothing.
    def word_attributes(id, sense, state)
      attributes =
        { type: "button", class: "reading-snippet__word", popovertarget: id }
      return attributes unless sense

      sense_id = sense.id
      state_class = "reading-snippet__word--#{state}" if state
      attributes.merge(
        class: ["reading-snippet__word", state_class],
        data: { sense_id:, action: "miss#view", miss_sense_id_param: sense_id },
      )
    end

    def word_state(sense)
      scores.fetch(sense.id) { unseen }.state(deck.round) if sense
    end

    # Shared by every word with no score, rather than built for each.
    def unseen = @unseen ||= SkillScore.new

    def senses
      @senses ||= Sense.where(id: sense_ids).index_by(&:id)
    end

    def scores
      @scores ||= deck.user.skill_scores
        .where(skill: deck.skill, sense_id: sense_ids).index_by(&:sense_id)
    end

    def sense_ids
      sentences = [*deck.source.front_matter, *snippets.flat_map(&:sentences)]
      sentences.flat_map(&:tokens).pluck("sense_id")
    end

    def data = { controller: "miss", miss_url_value: deck_misses_path(deck) }

    def classes
      [
        "reading-snippets",
        ("reading-snippets--readings" if language.readings),
      ]
    end

    def language = @language ||= deck.source.language
  end
end
