# frozen_string_literal: true

module Components
  # A Read-tab word's popover: its reading, or the word studied where the
  # text doesn't show it (a noun with its article, an abbreviation written
  # out), over its gloss; or, for a word the segmenter skipped, why it has
  # no card.
  class ReadingLookup < Components::Base
    SKIPS = { "name" => "name", "foreign" => "title in another language" }
      .freeze

    attr_accessor :id, :text, :sense, :skip, :language

    def initialize(id:, text:, sense:, skip:, language:)
      super()
      self.id = id
      self.text = text
      self.sense = sense
      self.skip = skip
      self.language = language
    end

    def view_template
      div(id:, popover: true, class: "reading-snippet__lookup") do
        div(class: "reading-snippet__lookup-label") { label } if label
        plain(sense ? sense.gloss : SKIPS[skip])
      end
    end

    private

    def label
      return unless sense

      entry = sense.entry
      return entry.reading if language.readings

      entry.term if entry.article || !entry.headword.casecmp?(text)
    end
  end
end
