# frozen_string_literal: true

module Views
  module Studies
    class Update < Views::Base
      include TextSizeData

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
          turbo_frame_tag(
            "study",
            class: "study-frame",
            data: text_size_data,
          ) do
            if result.level_completed?
              render_level_complete
              next
            end

            render(
              Components::SessionProgress.new(deck:, completed:, study_goal:),
            )

            render_card_result
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
        card = result.card

        div(data: controller_data) do
          div(class: "edit-card__front-wrapper") do
            args = {
              text: result.question,
              id: "card-question",
              reading: card.reading.to_s,
            }
            render(Components::CardFront.new(**args))
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

          render(Components::StudyExample.new(card:))

          ol(class: "study-answers-grid") do
            result.possible_answers.each do |answer|
              li do
                div(class: "answer-row #{answer_row_class(answer)}") do
                  span(class: "answer-number") { answer_badge(answer) }
                  answer_id =
                    ("correct-answer-text" if answer == result.correct_answer)
                  span(class: "answer-text", id: answer_id) { answer }
                end
              end
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
            deck_study_path(deck, exclude: result.card.id),
            data:,
            class: "hotkey-button next-card-button",
          ) do
            span { "Next Card" }
            span(class: "hotkey-hint") { "[space]" }
          end
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
