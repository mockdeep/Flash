# frozen_string_literal: true

module Components
  class StudyExample < Components::Base
    WRAPPER_ID = "study-example"

    def initialize(card:)
      super()
      @card = card
    end

    def view_template
      if example?
        div(id: WRAPPER_ID, data: wrapper_data) do
          render_toggle
          render_panel
        end
      else
        div(id: WRAPPER_ID)
      end
    end

    private

    def example?
      @card.example_front.present? && @card.example_back.present?
    end

    def wrapper_data
      {
        controller: "disclosure",
        action:
          "click@window->disclosure#handleDocClick " \
          "keydown@window->disclosure#handleEsc",
      }
    end

    def render_toggle
      button(
        type: "button",
        class: "study-example__toggle",
        aria: { expanded: "false" },
        data: toggle_data,
      ) do
        plain("💬 example")
        span(class: "hotkey-hint") { "[x]" }
      end
    end

    def toggle_data
      {
        disclosure_target: "toggle",
        action: "click->disclosure#toggle",
        hotkeys_target: "click",
        hotkey: "x",
      }
    end

    def render_panel
      div(
        class: "study-example",
        hidden: true,
        data: { disclosure_target: "panel" },
      ) do
        p(class: "study-example__label") { "Example" }
        render_close
        p(class: "study-example__front") { @card.example_front }
        p(class: "study-example__back") { @card.example_back }
      end
    end

    def render_close
      button(
        type: "button",
        class: "study-example__close",
        aria: { label: "Close example" },
        data: { action: "click->disclosure#close" },
      ) { "✕" }
    end
  end
end
