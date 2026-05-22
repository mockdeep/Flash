# frozen_string_literal: true

module Components
  class TextCsvInstructions < Components::Base
    def initialize(data: {})
      super()
      @data = data
    end

    def view_template
      div(class: "csv-instructions", data: @data) do
        render_header
        render_requirements
      end
    end

    private

    def render_header
      div(class: "csv-instructions-header") do
        span(class: "csv-icon") { "📄" }
        strong { "CSV Format Requirements" }
      end
    end

    def render_requirements
      ul(class: "csv-requirements") do
        li { "Required columns: front, back, and category" }
        li { "Optional column: distractors" }
        li { "Use ';' to separate multiple back answers or distractors" }
      end
    end
  end
end
