# frozen_string_literal: true

module Components
  class StudyExample < Components::Base
    WRAPPER_ID = "study-example"

    def initialize(card:)
      super()
      @card = card
    end

    def view_template
      div(id: WRAPPER_ID) do
        next if @card.example_front.blank? || @card.example_back.blank?

        div(class: "study-example") do
          p(class: "study-example__front") { @card.example_front }
          p(class: "study-example__back") { @card.example_back }
        end
      end
    end
  end
end
