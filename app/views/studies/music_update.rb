# frozen_string_literal: true

module Views
  module Studies
    class MusicUpdate < Views::Base
      LEVEL_BODY = "You've mastered all the cards at this level."

      attr_accessor :deck, :result, :completed, :study_goal, :demo

      def initialize(deck:, result:, completed:, study_goal:, demo: false)
        super()
        self.deck = deck
        self.result = result
        self.completed = completed
        self.study_goal = study_goal
        self.demo = demo
      end

      def view_template
        div(class: "content-container") do
          turbo_frame_tag("study") { render_frame }
        end
      end

      private

      def render_frame
        if result.level_completed?
          render_level_complete
        else
          render(progress_component)
          render_card_result
        end
      end

      def progress_component
        Components::SessionProgress.new(deck:, completed:, study_goal:)
      end

      def render_level_complete
        render_level_box(deck.level - 1)
        render_level_actions
      end

      def render_level_box(completed_level)
        div(class: "accent-box") do
          div(class: "accent-box__icon") { "🎉" }
          render_level_box_content(completed_level)
        end
      end

      def render_level_box_content(completed_level)
        div(class: "accent-box__content") do
          h2(class: "accent-box__heading") do
            "Level #{completed_level} Complete!"
          end
          p(class: "accent-box__text") { LEVEL_BODY }
        end
      end

      def render_level_actions
        div(class: "session-milestone-actions") do
          render_continue_link
          render_decks_link
        end
      end

      def render_continue_link
        link_to(
          "Continue to Level #{deck.level}",
          deck_study_path(deck),
          class: "session-milestone-primary",
        )
      end

      def render_decks_link
        link_to(
          "All Decks",
          decks_path,
          class: "session-milestone-secondary",
          data: { turbo_frame: "_top" },
        )
      end

      def render_card_result
        div(
          class: "music-study music-study--result",
          data: result_data,
        ) do
          render_card_front
          p(class: "music-study__sequence") { result.correct_answer }
          render_outcome
        end
      end

      def render_card_front
        args = { deck:, text: result.question, id: "card-question" }
        render(Components::CardFront.new(**args))
      end

      def result_data
        {
          controller: "auto-advance",
          auto_advance_frame_value: "study",
          auto_advance_url_value: deck_study_path(deck),
        }
      end

      def render_outcome
        if result.correct?
          p(class: "music-study__outcome music-study__outcome--correct") do
            "✓ Nailed it"
          end
        else
          p(class: "music-study__outcome music-study__outcome--incorrect") do
            "✗ Try again"
          end
        end
      end
    end
  end
end
