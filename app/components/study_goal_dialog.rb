# frozen_string_literal: true

module Components
  class StudyGoalDialog < Components::Base
    MODES = { "session" => "Daily goal", "target" => "Target date" }.freeze

    def initialize(deck:, study_goal:)
      super()
      @deck = deck
      @study_goal = study_goal
    end

    def view_template
      dialog(
        class: "dialog",
        data: {
          dialog_target: "dialog",
          action: "click->dialog#closeOnBackdropClick",
        },
      ) do
        render_header
        render_body
      end
    end

    private

    def render_header
      div(class: "dialog__header") do
        h2(class: "dialog__title") { "Study Goal" }
        button(
          type: "button",
          class: "dialog__close",
          data: { action: "click->dialog#close" },
        ) { "\u2715" }
      end
    end

    # The radios pick which form shows, in CSS (edit-card.css).
    def render_body
      div(class: "dialog__body") do
        div(class: "edit-card__goal-modes") do
          mode_radios
          MODES.each_key { |mode| goal_form(mode) }
        end
      end
    end

    def mode_radios
      fieldset(class: "deck-type-toggle") do
        MODES.each { |mode, text| mode_radio(mode, text) }
      end
    end

    def mode_radio(mode, text)
      label(class: "deck-type-option") do
        input(
          type: "radio",
          name: "goal_mode_choice",
          id: "goal-mode-#{mode}",
          value: mode,
          checked: @deck.goal_mode == mode,
        )
        plain(" #{text}")
      end
    end

    def goal_form(mode)
      render(
        Components::GoalForm.new(deck: @deck, mode:, study_goal: @study_goal),
      )
    end
  end
end
