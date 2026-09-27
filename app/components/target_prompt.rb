# frozen_string_literal: true

module Components
  # A note under the study progress bar when a level target needs the
  # learner's attention: its date passed, or its level was finished. Its
  # buttons open the goal dialog, so it renders inside SessionProgress.
  class TargetPrompt < Components::Base
    def initialize(deck:)
      super()
      @deck = deck
    end

    def view_template
      if @deck.target_missed?
        render_prompt(missed_text) { dialog_button("Pick a new date") }
      elsif @deck.target_reached?
        render_prompt(reached_text) do
          dialog_button("Set next target")
          not_now_button
        end
      end
    end

    private

    def render_prompt(text, &)
      div(class: "accent-box") do
        div(class: "accent-box__content") do
          p(class: "accent-box__text") { text }
          div(class: "target-prompt__actions", &)
        end
      end
    end

    def missed_text
      date = @deck.target_date.strftime("%b %-d")
      "You didn't finish level #{@deck.target_level} by #{date}, so " \
        "today's goal covers everything left."
    end

    def reached_text = "You finished level #{@deck.target_level}! 🎉"

    def dialog_button(text)
      button(
        type: "button",
        class: button_class(:secondary, :compact),
        data: { action: "click->dialog#open" },
      ) { text }
    end

    def not_now_button
      button_to(
        "Not now",
        deck_milestone_path(@deck),
        method: :patch,
        params: { deck: { goal_mode: "session" } },
        class: button_class(:ghost, :compact),
      )
    end
  end
end
