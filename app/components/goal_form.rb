# frozen_string_literal: true

module Components
  # One of the study-goal dialog's forms: a hand-set daily goal ("session")
  # or a level target ("target"). Each is a whole form with its own
  # goal_mode, so the dialog can show one and hide the other with CSS alone.
  class GoalForm < Components::Base
    def initialize(deck:, mode:, study_goal:)
      super()
      @deck = deck
      @mode = mode
      @study_goal = study_goal
    end

    def view_template
      form_with(**form_options) do |form|
        form.hidden_field(:goal_mode, value: @mode)
        div(class: "edit-card__fields") { render_fields(form) }
        render_actions(form)
      end
    end

    private

    # The namespace keeps field ids unique across the dialog's two forms.
    def form_options
      {
        model: @deck,
        url: deck_milestone_path(@deck),
        method: :patch,
        namespace: @mode,
        class: "edit-card__goal-form edit-card__goal-form--#{@mode}",
      }
    end

    def render_fields(form)
      if @mode == "target"
        render(
          Components::TargetGoalFields.new(
            form:, deck: @deck, study_goal: @study_goal,
          ),
        )
      else
        study_goal_field(form)
      end
    end

    def study_goal_field(form)
      div(class: "form-field") do
        form.label(:study_goal, "Cards per session", class: "form-label")
        form.number_field(
          :study_goal,
          min: 1,
          max: @deck.cards_count,
          required: true,
          class: "form-input",
        )
      end
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
