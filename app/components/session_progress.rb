# frozen_string_literal: true

module Components
  class SessionProgress < Components::Base
    def initialize(deck:, completed:, study_goal:)
      super()
      @deck = deck
      @completed = completed
      @study_goal = study_goal
    end

    def view_template
      div(class: "session-progress", data: { controller: "dialog" }) do
        render(Components::LevelProgress.new(deck: @deck))
        render_session_bar
        render_missed_target if @deck.target_missed?
      end
    end

    private

    def render_session_bar
      div(class: progress_bar_classes) do
        render_progress_bar
        render_progress_label
        render(
          Components::StudyGoalDialog.new(deck: @deck, study_goal: @study_goal),
        )
      end
    end

    def render_missed_target
      div(class: "accent-box") do
        div(class: "accent-box__content") do
          p(class: "accent-box__text") { missed_target_text }
          button(
            type: "button",
            class: button_class(:secondary, :compact),
            data: { action: "click->dialog#open" },
          ) { "Pick a new date" }
        end
      end
    end

    def missed_target_text
      level = @deck.target_level
      date = @deck.target_date.strftime("%b %-d")
      "You didn't finish level #{level} by #{date}, so today's goal " \
        "covers everything left."
    end

    def render_progress_bar
      progress(
        value: @completed,
        max: @study_goal,
        class: "progress-completed",
      )
    end

    def progress_bar_classes
      classes = "session-progress-bar"
      classes += " session-progress-bar-complete" if @completed >= @study_goal
      classes
    end

    def render_progress_label
      div(class: "progress-label") do
        plain("#{@completed} / ")
        button(
          type: "button",
          class: "milestone-goal-trigger",
          data: { action: "click->dialog#open" },
        ) { @study_goal.to_s }
        span(class: "progress-label__suffix") { " completed" }
      end
    end
  end
end
