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
            plain("#{done_count} / #{cards_count} cards done")

            h2(class: "card-front") { result.question }

            if result.correct?
              div(class: "result-card result-correct") do
                div(class: "result-icon") { "✓" }
                h2 { "Correct!" }
                p(class: "answer-display") do
                  strong { result.correct_answer }
                end
              end
            else
              div(class: "result-card result-incorrect") do
                div(class: "result-icon") { "✗" }
                h2 { "Not quite" }
                p(class: "correct-answer") do
                  plain("The correct answer was: ")
                  strong { result.correct_answer }
                end
              end
            end

            data = { hotkeys_target: "click", hotkey: " " }
            link_to(deck_study_path(deck), data:, class: "next-card-button") do
              span { "Next Card" }
              span(class: "hotkey-hint") { "Press Space" }
            end
          end
        end
      end
    end
  end
end
