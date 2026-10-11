# frozen_string_literal: true

module Components
  class StudyAnswers < Components::Base
    attr_accessor :deck, :study

    def initialize(deck:, study:)
      super()
      self.deck = deck
      self.study = study
    end

    def view_template
      case study.presentation_mode
      when :fuzzy_find then render(fuzzy_find_answers)
      when :fuzzy_reading
        hint("Type the reading")
        render(fuzzy_find_answers(stage: "reading"))
      when :reading
        hint("Pick the reading")
        render_answers(stage: "reading")
      else render_answers
      end
    end

    private

    def card = study.next_card

    def answers
      @answers ||= study.possible_answers
    end

    def hint(text)
      p(class: "keyboard-hint") { text }
    end

    def fuzzy_find_answers(stage: nil)
      FuzzyFindAnswers.new(deck:, card:, answers:, stage:)
    end

    def render_answers(stage: nil)
      ol(class: "study-answers-grid") do
        answers.each_with_index do |answer, index|
          li { render_answer(answer, index + 1, stage:) }
        end
      end
      hint("Press 1-5 to answer")
    end

    def render_answer(answer, number, stage:)
      button_to(
        deck_study_path(deck),
        data: { hotkeys_target: "click", hotkey: number.to_s },
        params: answer_params(answer, stage),
        method: :patch,
        class: "answer-button",
      ) do
        span(class: "answer-number") { number.to_s }
        span(class: "answer-text") { answer }
      end
    end

    def answer_params(answer, stage)
      fields = { answer:, card_id: card.id, possible_answers: answers, stage: }
      { answer: fields.compact }
    end
  end
end
