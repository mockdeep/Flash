# frozen_string_literal: true

module Components
  # The reading map's zoom and recenter buttons, each with its hotkey,
  # calling the `reading-map` controller around them.
  class MapControls < Components::Base
    # Each control's label with its text, hotkey and controller action.
    CONTROLS = {
      "Zoom out" => ["−", "-", "zoomOut"],
      "Zoom in" => ["+", "+", "zoomIn"],
      "Recenter" => ["Recenter", "c", "recenter"],
    }.freeze

    def view_template
      div(class: "reading-map__controls") do
        CONTROLS.each { |label, control| render_control(label, *control) }
      end
    end

    private

    def render_control(label, text, hotkey, action)
      data =
        { action: "reading-map##{action}", hotkeys_target: "click", hotkey: }
      look = button_class(:compact, :ghost)

      button(type: "button", class: look, aria: { label: }, data:) { text }
    end
  end
end
