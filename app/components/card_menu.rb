# frozen_string_literal: true

module Components
  class CardMenu < Components::Base
    SIZES = {
      "s" => "Small",
      "m" => "Medium",
      "l" => "Large",
      "xl" => "Extra large",
    }.freeze

    FONTS = {
      "hei" => "Hei",
      "song" => "Song",
      "kai" => "Kai",
      "hand" => "Calligraphy",
      "semantic" => "Semantic",
      "random" => "Random",
    }.freeze

    def initialize(font_menu: false)
      super()
      @font_menu = font_menu
    end

    def view_template
      render_toggle
      render_menu
    end

    private

    def render_toggle
      button(
        type: "button",
        class: "card-front__menu-toggle",
        aria: { label: "Card options", expanded: "false", haspopup: "menu" },
        data: {
          disclosure_target: "toggle",
          action: "click->disclosure#toggle",
        },
      ) { "⋯" }
    end

    def render_menu
      div(
        class: "card-front__menu",
        hidden: true,
        role: "menu",
        data: { disclosure_target: "panel" },
      ) do
        p(class: "card-front__menu-label") { "Text size" }
        SIZES.each { |code, label| render_size_option(code, label) }
        render_font_section if @font_menu
      end
    end

    def render_font_section
      p(class: "card-front__menu-label") { "Font" }
      FONTS.each { |code, label| render_font_option(code, label) }
    end

    def render_size_option(code, label)
      render_option(label, letter: "A", data: size_option_data(code))
    end

    def render_font_option(code, label)
      render_option(label, letter: "汉", data: font_option_data(code))
    end

    def render_option(label, letter:, data:)
      button(
        type: "button",
        class: "card-front__menu-option",
        role: "menuitemradio",
        aria: { checked: "false" },
        data:,
      ) do
        span(class: "card-front__menu-option-letter") { letter }
        span(class: "card-front__menu-option-label") { label }
      end
    end

    def size_option_data(code)
      {
        text_size_target: "option",
        size: code,
        action: "click->text-size#setSize click->disclosure#close",
      }
    end

    def font_option_data(code)
      {
        font_target: "option",
        font: code,
        action: "click->font#setFont click->disclosure#close",
      }
    end
  end
end
