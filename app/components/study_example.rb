# frozen_string_literal: true

module Components
  class StudyExample < Components::Base
    WRAPPER_ID = "study-example"

    def initialize(content:)
      super()
      @content = content
    end

    def view_template
      div(id: WRAPPER_ID) do
        next if @content.example_front.blank? || @content.example_back.blank?

        div(class: "study-example") do
          p(class: "study-example__front") { @content.example_front }
          p(class: "study-example__back") { @content.example_back }
        end
      end
    end
  end
end
