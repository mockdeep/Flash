# frozen_string_literal: true

module Components
  class NextDeckLink < Components::Base
    def initialize(deck:)
      super()
      @deck = deck
    end

    def view_template
      link_to(
        deck_study_path(@deck),
        class: "hotkey-button session-milestone-primary",
        data: { turbo_frame: "_top", hotkeys_target: "click", hotkey: " " },
      ) do
        span { "Next Deck" }
        span(class: "hotkey-hint") { "[space]" }
      end
    end
  end
end
