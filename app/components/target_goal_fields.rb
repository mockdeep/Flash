# frozen_string_literal: true

module Components
  # The study-goal dialog's "Target date" fields: which round to finish by
  # when, and today's goal worked out from a saved target.
  class TargetGoalFields < Components::Base
    def initialize(form:, deck:, study_goal:)
      super()
      @form = form
      @deck = deck
      @study_goal = study_goal
    end

    def view_template
      target_round_field
      target_date_field
      todays_goal if @deck.target_active?
    end

    private

    def target_round_field
      div(class: "form-field") do
        @form.label(:target_round, "Finish round", class: "form-label")
        @form.number_field(
          :target_round,
          min: @deck.round,
          required: true,
          class: "form-input",
        )
      end
    end

    def target_date_field
      div(class: "form-field") do
        @form.label(:target_date, "By date", class: "form-label")
        @form.date_field(
          :target_date,
          min: Date.current,
          required: true,
          class: "form-input",
        )
      end
    end

    def todays_goal
      div(class: "edit-card__goal-today") do
        p { "Today: #{@study_goal} cards" }
        @form.submit(
          "Recalculate",
          name: "recalculate",
          class: button_class(:secondary, :compact),
        )
      end
    end
  end
end
