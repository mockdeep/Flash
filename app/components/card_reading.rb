# frozen_string_literal: true

module Components
  class CardReading < Components::Base
    WRAPPER_ID = "card-reading"

    def initialize(reading:)
      super()
      @reading = reading
    end

    def view_template
      div(id: WRAPPER_ID, class: "card-reading") do
        next if @reading.blank?

        @reading
      end
    end
  end
end
