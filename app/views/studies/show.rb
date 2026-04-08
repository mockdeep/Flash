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

          card = study.next_card

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

            done_count = deck.cards.done(deck.level).count
            cards_count = deck.cards.count

            render_session_progress(done_count, cards_count)

            h2(class: "card-front") { card.front }

            render_answers(card, study.possible_answers)

            p(class: "keyboard-hint") { "Press 1-5 to answer" }

            # Claim the space hotkey to prevent scrolling down
            span(data: { hotkeys_target: "click", hotkey: " " }, hidden: true)
          end
        end
      end

      private

      def render_session_progress(done_count, cards_count)
        div(class: "session-progress") do
          div(class: "deck-progress-row") do
            render_stars(deck.level - 1)
            progress(value: done_count, max: cards_count, class: "progress-deck")
          end
          div(class: "session-progress-bar", data: { controller: "dialog" }) do
            progress(value: completed, max: study_goal, class: "progress-completed")
            div(class: "progress-label") do
              plain("#{completed} / ")
              button(
                type: "button",
                class: "milestone-goal-trigger",
                data: { action: "click->dialog#open" },
              ) { study_goal.to_s }
              plain(" completed")
            end
            render(Components::StudyGoalDialog.new(deck:, study_goal:))
          end
        end
      end

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

      def render_stars(completed_levels)
        div(class: "level-stars") do
          3.times do |i|
            if i < completed_levels
              span(class: "star star--filled") { "★" }
            else
              span(class: "star star--empty") { "★" }
            end
          end
          span(class: "level-label") { "Level #{completed_levels + 1}" }
        end
      end
    end
  end
end
