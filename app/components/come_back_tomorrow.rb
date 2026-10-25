# frozen_string_literal: true

module Components
  # Shown when every card left in the round was answered correctly today.
  class ComeBackTomorrow < Components::Base
    def initialize(deck:, demo:)
      super()
      @deck = deck
      @demo = demo
    end

    def view_template
      div(class: "accent-box") do
        div(class: "accent-box__icon") { "🌙" }
        div(class: "accent-box__content") { render_message }
      end
      div(class: "session-milestone-actions") { render_actions }
    end

    private

    def render_message
      h2(class: "accent-box__heading") { "That's all for today" }
      p(class: "accent-box__text") do
        <<~TEXT
          A card can move forward only once a day, and every card left in
          this round has already had its turn today. Come back tomorrow!
        TEXT
      end
    end

    def render_actions
      if @demo
        link_to("Sign Up Free", new_account_path, **link_options(:primary))
      else
        next_deck = @deck.user.next_unmet_deck
        render(Components::NextDeckLink.new(deck: next_deck)) if next_deck
        link_to("All Decks", decks_path, **link_options(:secondary))
      end
    end

    def link_options(kind)
      { class: "session-milestone-#{kind}", data: { turbo_frame: "_top" } }
    end
  end
end
