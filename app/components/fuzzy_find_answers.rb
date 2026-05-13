# frozen_string_literal: true

module Components
  class FuzzyFindAnswers < Components::Base
    INPUT_ID = "fuzzy-find-input"
    NO_AUTO = {
      autocomplete: "off",
      autocapitalize: "off",
      autocorrect: "off",
      spellcheck: "false",
    }.freeze

    attr_accessor :deck, :card, :answers

    def initialize(deck:, card:, answers:)
      super()
      self.deck = deck
      self.card = card
      self.answers = answers
    end

    def view_template
      div(class: "fuzzy-find", data: root_data) do
        render_form
        label(for: INPUT_ID, class: "form-label") { "Your answer" }
        render_input
        render_results_container
        render_no_matches
      end
    end

    private

    def root_data
      {
        controller: "fuzzy-find",
        fuzzy_find_answers_value: answers.to_json,
      }
    end

    def render_input
      input(**input_attrs)
    end

    def input_attrs
      {
        type: "text",
        id: INPUT_ID,
        class: "form-input fuzzy-find__input",
        autofocus: true,
        data: input_data,
        **NO_AUTO,
      }
    end

    def input_data
      {
        fuzzy_find_target: "input",
        action:
          "input->fuzzy-find#filter " \
          "keydown.enter->fuzzy-find#submitTop",
      }
    end

    def render_form
      form_with(
        url: deck_study_path(deck),
        method: :patch,
        data: { fuzzy_find_target: "form", turbo_frame: "study" },
      ) do |form|
        render_form_fields(form)
      end
    end

    def render_form_fields(form)
      form.hidden_field("answer[card_id]", value: card.id)
      form.hidden_field(
        "answer[answer]",
        data: { fuzzy_find_target: "answerInput" },
      )
      form.hidden_field(
        "answer[possible_answers][]",
        data: { fuzzy_find_target: "possibleAnswerInput" },
      )
    end

    def render_results_container
      ol(class: "study-answers-grid", data: { fuzzy_find_target: "results" })
    end

    def render_no_matches
      p(
        class: "fuzzy-find__no-matches",
        data: { fuzzy_find_target: "noMatches" },
        hidden: true,
      ) { "No matches" }
    end
  end
end
