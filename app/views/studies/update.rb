# frozen_string_literal: true

module Views
  module Studies
    class Update < Views::Base
      attr_accessor :deck, :result

      def initialize(deck:, result:)
        super()
        self.deck = deck
        self.result = result
      end

      def view_template
        div(class: "content-container") do
          turbo_frame_tag("study") do
            done_count = deck.cards.done.count
            cards_count = deck.cards.count
            progress(value: done_count, max: cards_count)
            div(class: "progress-text") do
              plain("#{done_count} / #{cards_count} cards done")
            end

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
            link_to(deck_study_path(deck), data:, class: "next-card-button") do
              span { "Next Card" }
              span(class: "hotkey-hint") { "Press Space" }
            end

            p(class: "keyboard-hint") { "Press Space to continue" }
          end
        end
      end

      private

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
