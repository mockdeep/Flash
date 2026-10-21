# frozen_string_literal: true

module Components
  class GuideReading < Components::Base
    TEXT_CLASSES = [
      "reading-snippets",
      "reading-snippets--readings",
      "reading-snippets--gaps",
    ].freeze

    def view_template
      section(id: "reading", class: "guide__section") do
        h2 { "The Read tab: words in real texts" }
        render_intro
        render(GuideExample.new(caption: "Words on the Read tab")) { sample }
        render_notes
      end
    end

    private

    def render_intro
      p do
        <<~TEXT
          Some language decks are built from real texts, like stories or
          articles. Their study page has a Read tab that shows the text, with
          each word marked by how well you know it.
        TEXT
      end
    end

    def sample
      div(class: TEXT_CLASSES) do
        div(class: "reading-snippet") do
          p do
            word("我", "wǒ", "done")
            word("喜欢", "xǐhuan")
            word("红", "hóng", "missed")
            word("花", "huā", "new")
          end
        end
      end
    end

    def word(text, reading, state = nil)
      classes = ["reading-snippet__word"]
      classes << "reading-snippet__word--#{state}" if state
      span(class: classes) do
        ruby do
          plain(text)
          rt { reading }
        end
      end
    end

    def render_notes
      ul do
        li { "Green words are done for this round" }
        li { "Grey words are ones you haven't studied yet" }
        li { "A word shows its reading above it until you get it right" }
        lookup_note
        spacing_note
      end
    end

    def lookup_note
      li do
        <<~TEXT
          Tap a word to see what it means. If it's a green word you've
          forgotten, press Restudy to bring it back when you study.
        TEXT
      end
    end

    def spacing_note
      li do
        <<~TEXT
          In rounds 1 and 2, words are spaced apart to help you see where each
          one starts. From round 3, the text reads normally.
        TEXT
      end
    end
  end
end
