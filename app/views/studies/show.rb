# frozen_string_literal: true

module Views
  module Studies
    class Show < Views::Base
      attr_accessor :deck, :study, :completed, :study_goal, :demo

      def initialize(deck:, study:, completed:, study_goal:, demo: false)
        super()
        self.deck = deck
        self.study = study
        self.completed = completed
        self.study_goal = study_goal
        self.demo = demo
      end

      def view_template
        div(class: "content-container") do
          if demo
            render(Components::DemoBanner.new)
          else
            link_to("View Deck", deck_path(deck))
            plain(" | ")
            link_to("All Decks", decks_path)
          end

          h1 { deck.name }

          turbo_frame_tag("study") do
            if deck.cards.none?
              div(class: "accent-box") do
                div(class: "accent-box__icon") { "📚" }
                div(class: "accent-box__content") do
                  h2(class: "accent-box__heading") { "No cards to study" }
                  p(class: "accent-box__text") { "This deck doesn't have any cards yet." }
                end
              end
              link_to("All Decks", decks_path, class: "button button--primary")
              next
            end

            render(
              Components::SessionProgress.new(deck:, completed:, study_goal:),
            )

            if completed >= study_goal
              render(Components::SessionMilestone.new(deck:, study_goal:, demo:))
            else
              card = study.next_card

              h2(class: "card-front") { card.front }

              render_answers(card, study.possible_answers)

              p(class: "keyboard-hint") { "Press 1-5 to answer" }
            end

            # Claim the space hotkey to prevent scrolling down
            span(data: { hotkeys_target: "click", hotkey: " " }, hidden: true)
          end
        end
      end

      private

      def render_answers(card, answers)
        ol(class: "study-answers-grid") do
          answers.each_with_index do |answer, index|
            li do
              params = {
                answer: { answer:, card_id: card.id, possible_answers: answers },
              }
              data = { hotkeys_target: "click", hotkey: (index + 1).to_s }
              button_to(
                deck_study_path(deck),
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
      end
    end
  end
end
