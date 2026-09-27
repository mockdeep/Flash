# frozen_string_literal: true

module Components
  class SessionMilestone < Components::Base
    def initialize(deck:, study_goal:, demo:)
      super()
      @deck = deck
      @study_goal = study_goal
      @demo = demo
    end

    def view_template
      div(class: "session-milestone") do
        p { "You've completed #{@study_goal} cards — nice work!" }
        div(class: "session-milestone-actions") { render_actions }
      end
    end

    private

    def render_actions
      if @demo
        sign_up_link
        keep_going_link
      else
        next_deck_action
        keep_going_link
        done_for_now_link
      end
    end

    def next_deck_action
      next_deck = @deck.user.next_unmet_deck
      next_deck ? next_deck_link(next_deck) : reset_goals_button
    end

    def next_deck_link(next_deck)
      link_to(
        deck_study_path(next_deck),
        class: "hotkey-button session-milestone-primary",
        data: { turbo_frame: "_top", hotkeys_target: "click", hotkey: " " },
      ) do
        span { "Next Deck" }
        span(class: "hotkey-hint") { "[space]" }
      end
    end

    def reset_goals_button
      button_to(
        study_goal_reset_path,
        class: "hotkey-button session-milestone-primary",
        form: { data: { turbo_frame: "_top" } },
        data: { hotkeys_target: "click", hotkey: " " },
      ) do
        span { "Reset All Goals" }
        span(class: "hotkey-hint") { "[space]" }
      end
    end

    def sign_up_link
      link_to(
        "Sign Up Free",
        new_account_path,
        class: "session-milestone-primary",
        data: { turbo_frame: "_top" },
      )
    end

    def keep_going_link
      link_to(
        deck_study_path(@deck, reset_session: true),
        class: "hotkey-button session-milestone-secondary",
        data: { hotkeys_target: "click", hotkey: "k" },
      ) do
        span { "Keep Going" }
        span(class: "hotkey-hint") { "[k]" }
      end
    end

    def done_for_now_link
      data = { turbo_frame: "_top", hotkeys_target: "click", hotkey: "Escape" }
      css_class = "hotkey-button session-milestone-secondary"
      link_to(root_path, class: css_class, data:) do
        span { "Done for Now" }
        span(class: "hotkey-hint") { "[esc]" }
      end
    end
  end
end
