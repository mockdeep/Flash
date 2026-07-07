# frozen_string_literal: true

module Components
  class CardFront < Components::Base
    def initialize(text:, id: nil, reading: nil, font_menu: false)
      super()
      @text = text
      @id = id
      @reading = reading
      @font_menu = font_menu
    end

    def view_template
      div(class: "card-front-wrapper", data: wrapper_data) do
        h2(class: "card-front", id: @id) { @text }
        render_reading
        render(Components::CardMenu.new(font_menu: @font_menu))
        render_hotkey_targets
      end
    end

    private

    def wrapper_data
      {
        controller: "disclosure",
        action:
          "click@window->disclosure#handleDocClick " \
          "keydown@window->disclosure#handleEsc",
      }
    end

    def render_reading
      return if @reading.nil?

      render(Components::CardReading.new(reading: @reading))
    end

    def render_hotkey_targets
      span(hidden: true, data: hotkey_data("[", "smaller"))
      span(hidden: true, data: hotkey_data("]", "larger"))
    end

    def hotkey_data(key, action)
      {
        hotkeys_target: "click",
        hotkey: key,
        action: "click->text-size##{action}",
      }
    end
  end
end
