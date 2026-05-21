# frozen_string_literal: true

module Components
  class CardFront < Components::Base
    SIZES = [
      ["s", "Small"],
      ["m", "Medium"],
      ["l", "Large"],
      ["xl", "Extra large"],
    ].freeze

    def initialize(deck:, text:, id: nil)
      super()
      @deck = deck
      @text = text
      @id = id
    end

    def view_template
      div(class: "card-front-wrapper", data: wrapper_data) do
        h2(class: "card-front", id: @id) { @text }
        render_menu_toggle
        render_menu
        render_hotkey_targets
      end
    end

    private

    def wrapper_data
      {
        controller: "card-size",
        card_size_deck_id_value: @deck.id,
        size: "m",
        action: wrapper_actions,
      }
    end

    def wrapper_actions
      [
        "click@window->card-size#handleDocClick",
        "keydown@window->card-size#handleEsc",
      ].join(" ")
    end

    def render_menu_toggle
      button(
        type: "button",
        class: "card-front__menu-toggle",
        aria: { label: "Card options", expanded: "false", haspopup: "menu" },
        data: menu_toggle_data,
      ) { "⋯" }
    end

    def menu_toggle_data
      { card_size_target: "toggle", action: "click->card-size#toggleMenu" }
    end

    def render_menu
      div(
        class: "card-front__menu",
        hidden: true,
        role: "menu",
        data: { card_size_target: "menu" },
      ) do
        p(class: "card-front__menu-label") { "Text size" }
        SIZES.each { |code, label| render_option(code, label) }
      end
    end

    def render_option(code, label)
      button(
        type: "button",
        class: "card-front__menu-option",
        role: "menuitemradio",
        aria: { checked: "false" },
        data: option_data(code),
      ) do
        span(class: "card-front__menu-option-letter") { "A" }
        span(class: "card-front__menu-option-label") { label }
      end
    end

    def option_data(code)
      {
        card_size_target: "option",
        size: code,
        action: "click->card-size#setSize",
      }
    end

    def render_hotkey_targets
      span(hidden: true, data: hotkey_data("[", "smaller"))
      span(hidden: true, data: hotkey_data("]", "larger"))
    end

    def hotkey_data(key, action)
      {
        hotkeys_target: "click",
        hotkey: key,
        action: "click->card-size##{action}",
      }
    end
  end
end
