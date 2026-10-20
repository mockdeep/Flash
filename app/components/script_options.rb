# frozen_string_literal: true

module Components
  # The card menu's Characters section on a Mandarin deck. The script is the
  # deck's, so picking one saves it and reloads the page, Read tab and all.
  class ScriptOptions < Components::Base
    SCRIPTS = {
      "simplified" => ["简", "Simplified"],
      "traditional" => ["繁", "Traditional"],
    }.freeze

    def initialize(deck:)
      super()
      @deck = deck
    end

    def view_template
      p(class: "card-front__menu-label") { "Characters" }
      SCRIPTS.each do |script, (letter, label)|
        render_option(script, letter, label)
      end
    end

    private

    def render_option(script, letter, label)
      button_to(deck_script_path(@deck), **option_attributes(script)) do
        span(class: "card-front__menu-option-letter") { letter }
        span(class: "card-front__menu-option-label") { label }
      end
    end

    def option_attributes(script)
      {
        method: :patch,
        params: { script: },
        class: "card-front__menu-option",
        role: "menuitemradio",
        aria: { checked: (@deck.script == script).to_s },
        form: { data: { turbo_frame: "_top" } },
      }
    end
  end
end
