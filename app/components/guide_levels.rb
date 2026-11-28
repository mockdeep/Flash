# frozen_string_literal: true

module Components
  class GuideLevels < Components::Base
    def view_template
      section(id: "levels", class: "guide__section") do
        h2 { "Levels: from recognizing to remembering" }
        render_intro
        div(class: "guide__examples") do
          level_one
          level_two
          level_three
        end
        render_notes
      end
    end

    private

    def render_intro
      p do
        <<~TEXT
          Each card climbs three levels. A right answer moves it up one level,
          once a day, and a wrong answer sends it back to level 1. Once you've
          answered it right at level 3, the card is finished.
        TEXT
      end
      p { "Here's one card, 花 (flower), as it changes from level to level." }
    end

    def level_one
      example(
        "Level 1: pick the meaning",
        hint: "Press 1-5 to answer",
        choices: ["tree", "flower", "grass", "to eat", "red"],
      )
    end

    def level_two
      example(
        "Level 2: pick the reading, then the meaning",
        hint: "Pick the reading",
        choices: ["huà", "hǎo", "huā", "huǒ", "hē"],
      )
    end

    def level_three
      example(
        "Level 3: type the reading, then the meaning",
        hint: "Type the reading",
        typed: "hua",
        choices: ["huā", "huà"],
      )
    end

    def example(caption, **)
      render(GuideExample.new(caption:)) do
        render(GuideCard.new(front: "花", **))
      end
    end

    def render_notes
      ul do
        order_note
        typing_note
        readings_note
        bar_note
      end
    end

    def order_note
      li do
        <<~TEXT
          Each day starts with the cards closest to finished: level 3 first,
          then level 2, then level 1 and new cards. In a deck made from a
          text, cards come in the order the text uses their words.
        TEXT
      end
    end

    def typing_note
      li do
        <<~TEXT
          Multiple choice gets you started. Typing the answer shows you really
          remember it, not just recognize it. As you type, Flash lists the
          answers that start with what you've typed, and you pick one. Tone
          marks can be left out, so "hua" finds both huā and huà.
        TEXT
      end
    end

    def readings_note
      li do
        <<~TEXT
          Readings, like pinyin, are only asked for on cards that have
          them. Other cards skip straight to the meaning.
        TEXT
      end
    end

    def bar_note
      li do
        <<~TEXT
          The bar at the top of the study page shows how many of the deck's
          cards are finished and how many sit at each level.
        TEXT
      end
    end
  end
end
