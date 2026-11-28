# frozen_string_literal: true

module Components
  # A note under the study progress bar when a target date needs the
  # learner's attention: it passed, or the deck was finished. Its buttons
  # open the goal dialog, so it renders inside SessionProgress.
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
          dialog_button("Set next target") unless @deck.all_done?
          daily_goal_button
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
      "You didn't get through #{@deck.target_label} by #{date}, so " \
        "today's goal covers everything left."
    end

    def reached_text = "You got through #{@deck.target_label} on time! 🎉"

    def dialog_button(text)
      button(
        type: "button",
        class: button_class(:secondary, :compact),
        data: { action: "click->dialog#open" },
      ) { text }
    end

    def daily_goal_button
      button_to(
        "Back to a daily goal",
        deck_milestone_path(@deck),
        method: :patch,
        params: { deck: { goal_mode: "session" } },
        class: button_class(:ghost, :compact),
      )
    end
  end
end
