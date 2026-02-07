# frozen_string_literal: true

module Views
  module Studies
    class Show < Views::Base
      attr_accessor :deck, :study

      def initialize(deck:, study:)
        super()
        self.deck = deck
        self.study = study
      end

      def view_template
        div(class: "content-container") do
          link_to("View Deck", deck_path(deck))
          plain(" | ")
          link_to("All Decks", decks_path)

          h1 { deck.name }

          card = study.next_card

          turbo_frame_tag("study") do
            done_count = deck.cards.done.count
            cards_count = deck.cards.count
            progress(value: done_count, max: cards_count)
            div(class: "progress-text") do
              plain("#{done_count} / #{cards_count} cards done")
            end

            h2(class: "card-front") { card.front }

            ol(class: "study-answers-grid") do
              study.possible_answers.each_with_index do |answer, index|
                li do
                  params = { answer: { answer:, card_id: card.id } }
                  path = deck_study_path(deck)
                  data = { hotkeys_target: "click", hotkey: (index + 1).to_s }
                  button_to(
                    path,
                    data:,
                    params:,
                    method: :patch,
                    class: "answer-button",
                  ) do
                    span(class: "answer-number") { (index + 1).to_s }
                    span(class: "answer-text") { answer }
                  end
                end
              end
            end

            p(class: "keyboard-hint") { "Press 1-5 to answer" }
          end
        end
      end
    end
  end
end
