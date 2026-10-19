# frozen_string_literal: true

module Components
  # A still picture of a study card for the guide: the card front and its
  # answer choices, styled like the real thing but not clickable.
  class GuideCard < Components::Base
    def initialize(front:, hint:, choices:, typed: nil)
      super()
      @front = front
      @hint = hint
      @choices = choices
      @typed = typed
    end

    def view_template
      div(class: "guide-card") do
        div(class: "card-front-wrapper") do
          h2(class: "card-front") { @front }
        end
        p(class: "keyboard-hint") { @hint }
        render_typed if @typed
        render_choices
      end
    end

    private

    def render_typed
      div(class: "form-input fuzzy-find__input") { @typed }
    end

    def render_choices
      ol(class: "study-answers-grid") do
        @choices.each_with_index do |choice, index|
          li { render_choice(choice, index) }
        end
      end
    end

    def render_choice(choice, index)
      div(class: "answer-row") do
        span(class: "answer-number") { (index + 1).to_s } unless @typed
        span(class: "answer-text") { choice }
      end
    end
  end
end
