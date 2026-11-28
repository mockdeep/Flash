# frozen_string_literal: true

module Components
  # The study-goal dialog's "Target date" fields: what to finish (the deck,
  # or for a text with more than one chapter, up to a chapter), when by,
  # and today's goal worked out from a saved target.
  class TargetGoalFields < Components::Base
    def initialize(form:, deck:, study_goal:)
      super()
      @form = form
      @deck = deck
      @study_goal = study_goal
    end

    def view_template
      target_snippet_field if chapters.many?
      target_date_field
      todays_goal if @deck.target_active?
    end

    private

    def chapters = @deck.source&.studyable_snippets.to_a

    def target_snippet_field
      options = chapters.map { ["Up to #{it.label}", it.id] }
      options.unshift(["The whole deck", ""])
      div(class: "form-field") do
        @form.label(:target_snippet_id, "Finish", class: "form-label")
        @form.select(:target_snippet_id, options, {}, class: "form-input")
      end
    end

    def target_date_field
      div(class: "form-field") do
        @form.label(:target_date, "By", class: "form-label")
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
