# frozen_string_literal: true

module Views
  module Studies
    class Update < Views::Base
      include StudyPageData

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
        div(class: "content-container study-page", data: study_page_data) do
          turbo_frame_tag("study", class: "study-frame") do
            if result.round_completed?
              render_round_complete
              next
            end

            render(
              Components::SessionProgress.new(deck:, completed:, study_goal:),
            )
            render(Components::PracticeLabel.new) if result.practice?

            render_card_result
            unless deck.flat_cards?
              render(Components::WordStates.new(deck:, card: result.card))
            end
          end
          render_text_size_hotkeys
        end
      end

      private

      def render_round_complete
        completed_round = deck.round - 1
        div(class: "accent-box") do
          div(class: "accent-box__icon") { "🎉" }
          div(class: "accent-box__content") do
            h2(class: "accent-box__heading") do
              "Round #{completed_round} Complete!"
            end
            render(Components::RoundProgress.new(deck:))
            p(class: "accent-box__text") do
              "You've mastered all the cards in this round."
            end
          end
        end
        div(class: "session-milestone-actions") do
          # The whole page, so the Read tab picks up the new round.
          link_to(
            "Continue to Round #{deck.round}",
            deck_study_path(deck),
            class: "session-milestone-primary",
            data: { turbo_frame: "_top" },
          )
          link_to(
            "All Decks",
            decks_path,
            class: "session-milestone-secondary",
            data: { turbo_frame: "_top" },
          )
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
              deck:,
              reading: card.reading.to_s,
              card_id: card.id,
            }
            render(Components::CardFront.new(**args))
            if editable?
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
            render(Components::StudyExample.new(card:))
          end

          ol(class: "study-answers-grid") do
            result.possible_answers.each do |answer|
              li do
                div(class: "answer-row #{answer_row_class(answer)}") do
                  span(class: "answer-number") { answer_badge(answer) }
                  answer_id =
                    ("correct-answer-text" if answer == result.correct_answer)
                  span(class: "answer-text", id: answer_id) { answer }
                  render_streak_pips if show_streak_pips?(answer)
                end
              end
            end
          end

          if editable?
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
            next_card_path,
            data:,
            class: "hotkey-button next-card-button",
          ) do
            span { "Next Card" }
            span(class: "hotkey-hint") { "[space]" }
          end
        end
      end

      def next_card_path
        practice = (true if result.practice?)
        deck_study_path(deck, exclude: result.card.id, practice:)
      end

      # Card editing is a flat-card affair: language cards read their content
      # from the shared compendium, so there is nothing card-local to edit.
      def editable? = !demo && deck.flat_cards?

      def show_streak_pips?(answer)
        answer == result.correct_answer && result.correct? && deck.round > 1
      end

      def render_streak_pips
        filled = [result.card.correct_streak, deck.round].min
        span(class: "answer-streak") do
          span(class: "answer-streak__pips", aria: { hidden: "true" }) do
            deck.round.times do |i|
              span(class: ["streak-pip", ("streak-pip--filled" if i < filled)])
            end
          end
          span(class: "answer-streak__count") { "#{filled}/#{deck.round}" }
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
