# frozen_string_literal: true

module Views
  module Studies
    class Update < Views::Base
      attr_accessor :deck, :result, :reviewed, :completed, :demo

      def initialize(deck:, result:, reviewed:, completed:, demo: false)
        super()
        self.deck = deck
        self.result = result
        self.reviewed = reviewed
        self.completed = completed
        self.demo = demo
      end

      def view_template
        div(class: "content-container") do
          turbo_frame_tag("study") do
            done_count = deck.cards.done.count
            cards_count = deck.cards.count

            div(class: "session-progress") do
              progress(
                value: done_count,
                max: cards_count,
                class: "progress-deck",
              )
              completed_classes = "session-progress-bar"
              if completed == 25
                completed_classes += " session-progress-bar-complete"
              end
              div(class: completed_classes) do
                progress(value: completed, max: 25, class: "progress-completed")
                div(class: "progress-label") do
                  plain("#{completed} / 25 completed")
                end
              end
              div(class: "session-progress-bar") do
                progress(value: reviewed, max: 100, class: "progress-reviewed")
                div(class: "progress-label") do
                  plain("#{reviewed} / 100 reviewed")
                end
              end
            end

            if reviewed >= 100
              render_milestone
              span(data: { hotkeys_target: "click", hotkey: " " }, hidden: true)
            else
              render_card_result
            end
          end
        end
      end

      private

      def render_milestone
        div(class: "session-milestone") do
          p { "You've reviewed 100 cards — nice work!" }
          div(class: "session-milestone-actions") do
            if demo
              link_to(
                "Sign Up Free",
                new_account_path,
                class: "session-milestone-primary",
                data: { turbo_frame: "_top" },
              )
              link_to(
                "Keep Going",
                deck_study_path(deck, reset_session: true),
                class: "session-milestone-secondary",
              )
            else
              link_to(
                "Keep Going",
                deck_study_path(deck, reset_session: true),
                class: "session-milestone-primary",
              )
              link_to(
                "Done for Now",
                root_path,
                class: "session-milestone-secondary",
                data: { turbo_frame: "_top" },
              )
            end
          end
        end
      end

      def render_card_result
        h2(class: "card-front") { result.question }

        ol(class: "study-answers-grid") do
          result.possible_answers.each do |answer|
            css_class = answer_row_class(answer)
            li do
              div(class: "answer-row #{css_class}") do
                span(class: "answer-number") { answer_badge(answer) }
                span(class: "answer-text") { answer }
              end
            end
          end
        end

        data = { hotkeys_target: "click", hotkey: " " }
        link_to(
          deck_study_path(deck),
          data:,
          class: "next-card-button",
        ) do
          span { "Next Card" }
          span(class: "hotkey-hint") { "[space]" }
        end
      end

      def answer_row_class(answer)
        if answer == result.correct_answer
          "answer-correct"
        elsif answer == result.selected_answer
          "answer-incorrect"
        else
          "answer-faded"
        end
      end

      def answer_badge(answer)
        if answer == result.correct_answer
          "✓"
        elsif answer == result.selected_answer
          "✗"
        else
          ""
        end
      end
    end
  end
end
