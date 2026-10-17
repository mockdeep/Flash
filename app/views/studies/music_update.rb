# frozen_string_literal: true

module Views
  module Studies
    class MusicUpdate < Views::Base
      include StudyPageData

      ROUND_BODY = "You've mastered all the cards in this round."

      attr_accessor :deck, :result, :demo

      def initialize(deck:, result:, demo: false)
        super()
        self.deck = deck
        self.result = result
        self.demo = demo
      end

      def view_template
        div(class: "content-container study-page", data: study_page_data) do
          turbo_frame_tag("study", class: "study-frame") { render_frame }
          render_text_size_hotkeys
        end
      end

      private

      def render_round_progress
        div(class: "session-progress") do
          render(Components::RoundProgress.new(deck:))
        end
      end

      def render_frame
        if result.round_completed?
          render_round_complete
        else
          render_round_progress
          render_card_result
        end
      end

      def render_round_complete
        render_round_box(deck.round - 1)
        render_round_actions
      end

      def render_round_box(completed_round)
        div(class: "accent-box") do
          div(class: "accent-box__icon") { "🎉" }
          div(class: "accent-box__content") do
            h2(class: "accent-box__heading") do
              "Round #{completed_round} Complete!"
            end
            p(class: "accent-box__text") { ROUND_BODY }
          end
        end
      end

      def render_round_actions
        div(class: "session-milestone-actions") do
          render_continue_link
          render_decks_link
        end
      end

      def render_continue_link
        link_to(
          "Continue to Round #{deck.round}",
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
        args = { text: result.question, id: "card-question" }
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
