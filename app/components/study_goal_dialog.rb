# frozen_string_literal: true

module Components
  class StudyGoalDialog < Components::Base
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

    def render_body
      div(class: "dialog__body") do
        form_with(
          url: deck_milestone_path(@deck),
          method: :patch,
        ) do |form|
          render_field(form)
          render_actions(form)
        end
      end
    end

    def render_field(form)
      div(class: "edit-card__fields") do
        div(class: "form-field") do
          form.label(:study_goal, "Cards per session", class: "form-label")
          study_goal_input(form)
        end
      end
    end

    def study_goal_input(form)
      form.number_field(
        :study_goal,
        value: @study_goal,
        min: 1,
        max: @deck.cards.count,
        required: true,
        class: "form-input",
      )
    end

    def render_actions(form)
      div(class: "edit-card__actions") do
        button(
          type: "button",
          class: button_class(:ghost, :compact),
          data: { action: "click->dialog#close" },
        ) { "Cancel" }
        form.submit("Save", class: button_class(:primary, :compact))
      end
    end
  end
end
