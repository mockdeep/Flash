# frozen_string_literal: true

module Components
  # A Read-tab word's popover: its reading, or the word studied where the
  # text doesn't show it (a noun with its article, an abbreviation written
  # out), over its gloss, and once the word is done at the deck's round, a
  # Restudy button; or, for a word the segmenter skipped, why it has no card.
  class ReadingLookup < Components::Base
    SKIPS = {
      "emoticon" => "emoticon",
      "foreign" => "in another language",
      "name" => "name",
    }.freeze

    attr_accessor :id, :text, :sense, :skip, :state

    def initialize(id:, text:, sense:, skip:, state:)
      super()
      self.id = id
      self.text = text
      self.sense = sense
      self.skip = skip
      self.state = state
    end

    def view_template
      div(id:, popover: true, class: classes, data:) do
        div(class: "reading-snippet__lookup-label") { label } if label
        plain(sense ? sense.gloss : SKIPS[skip])
        restudy_button if sense
      end
    end

    private

    # Always rendered, so it can show once an answer marks the word done; CSS
    # hides it until then.
    def restudy_button
      button(
        type: "button",
        class: [button_class(:compact), "reading-snippet__restudy"],
        data: { action: "miss#restudy", miss_sense_id_param: sense.id },
      ) { "Restudy" }
    end

    def classes
      [
        "reading-snippet__lookup",
        ("reading-snippet__lookup--done" if state == "done"),
      ]
    end

    def data
      { sense_id: sense.id } if sense
    end

    def label
      return unless sense

      entry = sense.entry
      return entry.reading if Language.for(entry.language).readings

      entry.term if entry.article || !entry.headword.casecmp?(text)
    end
  end
end
