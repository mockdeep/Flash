# frozen_string_literal: true

module Components
  # Shown once every card in the deck is finished.
  class DeckFinished < Components::Base
    def initialize(deck:, demo:)
      super()
      @deck = deck
      @demo = demo
    end

    def view_template
      div(class: "accent-box") do
        div(class: "accent-box__icon") { "🎉" }
        div(class: "accent-box__content") { render_message }
      end
      div(class: "session-milestone-actions") { render_actions }
    end

    private

    def render_message
      h2(class: "accent-box__heading") { "Deck finished" }
      p(class: "accent-box__text") do
        "Every card in this deck has made it through all #{Deck::LEVELS} " \
          "levels."
      end
    end

    def render_actions
      if @demo
        link_to("Sign Up Free", new_account_path, **link_options(:primary))
      else
        next_deck = @deck.user.next_unmet_deck(after: @deck)
        render(Components::NextDeckLink.new(deck: next_deck)) if next_deck
        link_to("All Decks", decks_path, **link_options(:secondary))
      end
    end

    def link_options(kind)
      { class: "session-milestone-#{kind}", data: { turbo_frame: "_top" } }
    end
  end
end
