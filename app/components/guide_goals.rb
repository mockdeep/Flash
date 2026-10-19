# frozen_string_literal: true

module Components
  class GuideGoals < Components::Base
    def view_template
      section(id: "goals", class: "guide__section") do
        h2 { "Goals: how much to study each day" }
        render_intro
        dl { goal_kinds }
        render_milestone
      end
    end

    private

    def render_intro
      p do
        <<~TEXT
          Each deck has a goal you can change from its study page. There are
          three kinds:
        TEXT
      end
    end

    def goal_kinds
      goal("No goal", <<~TEXT)
        Study as much as you like. Flash counts the cards you finish each
        day.
      TEXT
      goal("Daily goal", <<~TEXT)
        Pick how many cards to finish each day, and Flash shows your progress
        toward it.
      TEXT
      target_goal
    end

    def target_goal
      goal("Target date", <<~TEXT)
        Pick a round to finish and a date to finish it by. Flash works out how
        many cards you need each day to get there. Do extra today, and
        tomorrow's goal goes down. If you miss the date, Flash asks you to
        pick a new one.
      TEXT
    end

    def goal(name, text)
      dt { name }
      dd { text }
    end

    def render_milestone
      p { "When you reach a goal, you can:" }
      ul do
        action("Next Deck", "move on to a deck that hasn't reached its goal.")
        action("Keep Going", "study another batch of the same deck.")
        action("Reset All Goals", <<~TEXT)
          shown when every deck is done, to start again on all of them.
        TEXT
      end
    end

    def action(name, text)
      li do
        strong { "#{name}:" }
        plain(" #{text}")
      end
    end
  end
end
