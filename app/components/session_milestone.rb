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
        keep_going_link("session-milestone-secondary")
      else
        keep_going_link("session-milestone-primary")
        done_for_now_link
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

    def keep_going_link(css_class)
      link_to(
        deck_study_path(@deck, reset_session: true),
        class: css_class,
        data: { hotkeys_target: "click", hotkey: " " },
      ) do
        span { "Keep Going" }
        span(class: "hotkey-hint") { "[space]" }
      end
    end

    def done_for_now_link
      data = { turbo_frame: "_top", hotkeys_target: "click", hotkey: "Escape" }
      link_to(root_path, class: "session-milestone-secondary", data:) do
        span { "Done for Now" }
        span(class: "hotkey-hint") { "[esc]" }
      end
    end
  end
end
