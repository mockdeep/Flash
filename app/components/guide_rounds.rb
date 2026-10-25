# frozen_string_literal: true

module Components
  class GuideRounds < Components::Base
    def view_template
      section(id: "rounds", class: "guide__section") do
        h2 { "Rounds: from recognizing to remembering" }
        render_intro
        div(class: "guide__examples") do
          round_one
          round_two
          round_three
        end
        render_notes
      end
    end

    private

    def render_intro
      p do
        <<~TEXT
          A deck is studied in rounds. To finish a round, you get every card
          right a number of times in a row, each on a different day: once in
          round 1, twice in round 2, three times in round 3. A wrong answer
          starts that card's count over. When every card is done, the deck
          moves to the next round.
        TEXT
      end
      p { "Here's one card, 花 (flower), as it changes from round to round." }
    end

    def round_one
      example(
        "Round 1: pick the meaning",
        hint: "Press 1-5 to answer",
        choices: ["tree", "flower", "grass", "to eat", "red"],
      )
    end

    def round_two
      example(
        "Round 2: pick the reading, then the meaning",
        hint: "Pick the reading",
        choices: ["huà", "hǎo", "huā", "huǒ", "hē"],
      )
    end

    def round_three
      example(
        "Round 3: type the reading, then the meaning",
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
        typing_note
        readings_note
        window_note
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

    def window_note
      li do
        <<~TEXT
          Each round brings more cards into play at once, and the bar at the
          top of the study page shows how far through the round you are.
        TEXT
      end
    end
  end
end
