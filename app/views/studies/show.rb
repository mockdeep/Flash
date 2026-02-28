# frozen_string_literal: true

module Views
  module Studies
    class Show < Views::Base
      attr_accessor :deck, :study, :reviewed, :completed

      def initialize(deck:, study:, reviewed:, completed:)
        super()
        self.deck = deck
        self.study = study
        self.reviewed = reviewed
        self.completed = completed
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

            h2(class: "card-front") { card.front }

            answers = study.possible_answers
            ol(class: "study-answers-grid") do
              answers.each_with_index do |answer, index|
                li do
                  params = {
                    answer: {
                      answer:,
                      card_id: card.id,
                      possible_answers: answers,
                    },
                  }
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

            # Claim the space hotkey to prevent scrolling down
            span(data: { hotkeys_target: "click", hotkey: " " }, hidden: true)
          end
        end
      end
    end
  end
end
