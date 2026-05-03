# frozen_string_literal: true

module Views
  module Studies
    class Update < Views::Base
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
          turbo_frame_tag("study") do
            if result.level_completed?
              render_level_complete
              next
            end

            render(
              Components::SessionProgress.new(deck:, completed:, study_goal:),
            )

            if result.correct?
              render_card_result
            else
              render_retry
            end
          end
        end
      end

      private

      def render_level_complete
        completed_level = deck.level - 1
        div(class: "accent-box") do
          div(class: "accent-box__icon") { "🎉" }
          div(class: "accent-box__content") do
            h2(class: "accent-box__heading") do
              "Level #{completed_level} Complete!"
            end
            render_stars(completed_level)
            p(class: "accent-box__text") do
              "You've mastered all the cards at this level."
            end
          end
        end
        div(class: "session-milestone-actions") do
          link_to(
            "Continue to Level #{deck.level}",
            deck_study_path(deck),
            class: "session-milestone-primary",
          )
          link_to(
            "All Decks",
            decks_path,
            class: "session-milestone-secondary",
            data: { turbo_frame: "_top" },
          )
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

      def render_card_result
        controller_data = demo ? {} : { controller: "dialog" }

        div(data: controller_data) do
          div(class: "edit-card__front-wrapper") do
            h2(class: "card-front", id: "card-question") { result.question }
            unless demo
              button(
                type: "button",
                class: "edit-card__trigger",
                aria: { label: "Edit card" },
                data: {
                  action: "click->dialog#open",
                  hotkeys_target: "click",
                  hotkey: "e",
                },
              ) { "✏" }
            end
          end

          ol(class: "study-answers-grid") do
            result.possible_answers.each do |answer|
              render_answered_row(answer)
            end
          end

          unless demo
            dialog(
              class: "dialog",
              data: {
                dialog_target: "dialog",
                action: "click->dialog#closeOnBackdropClick",
              },
            ) do
              div(class: "dialog__header") do
                h2(class: "dialog__title") { "Edit Card" }
                button(
                  type: "button",
                  class: "dialog__close",
                  data: { action: "click->dialog#close" },
                ) { "✕" }
              end
              div(class: "dialog__body") do
                render(Views::Cards::EditForm.new(deck:, card: result.card))
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
      end

      def render_retry
        h2(class: "card-front") { result.question }

        ol(class: "study-answers-grid study-answers-grid--retry") do
          result.possible_answers.each_with_index do |answer, index|
            li do
              if result.wrong_answers.include?(answer)
                render_eliminated_answer(answer)
              else
                render_answer_button(answer, index)
              end
            end
          end
        end

        p(class: "keyboard-hint") { "Press 1-5 to answer" }
        span(data: { hotkeys_target: "click", hotkey: " " }, hidden: true)
      end

      def render_answered_row(answer)
        correct = answer == result.correct_answer
        css_class = correct ? "answer-correct" : "answer-faded"
        li do
          div(class: "answer-row #{css_class}") do
            span(class: "answer-number") { correct ? "✓" : "" }
            answer_id = ("correct-answer-text" if correct)
            span(class: "answer-text", id: answer_id) { answer }
          end
        end
      end

      def render_eliminated_answer(answer)
        div(class: "answer-row answer-incorrect") do
          span(class: "answer-number") { "✗" }
          span(class: "answer-text") { answer }
        end
      end

      def render_answer_button(answer, index)
        params = {
          answer: {
            answer:,
            card_id: result.card.id,
            possible_answers: result.possible_answers,
            wrong_answers: result.wrong_answers,
          },
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
