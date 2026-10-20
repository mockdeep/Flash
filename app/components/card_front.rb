# frozen_string_literal: true

module Components
  class CardFront < Components::Base
    def initialize(text:, deck:, id: nil, reading: nil, card_id: nil)
      super()
      @text = text
      @deck = deck
      @id = id
      @reading = reading
      @card_id = card_id
    end

    def view_template
      div(class: "card-front-wrapper", data: wrapper_data) do
        h2(class: "card-front", id: @id) { @text }
        render_reading
        render(Components::CardMenu.new(deck: @deck))
      end
    end

    private

    def wrapper_data
      data = {
        controller: "disclosure",
        action:
          "click@window->disclosure#handleDocClick " \
          "keydown@window->disclosure#handleEsc",
      }
      return data if @card_id.nil?

      data.merge(font_target: "card", card_id: @card_id)
    end

    def render_reading
      return if @reading.nil?

      render(Components::CardReading.new(reading: @reading))
    end
  end
end
