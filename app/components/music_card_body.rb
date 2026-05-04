# frozen_string_literal: true

module Components
  class MusicCardBody < Components::Base
    attr_accessor :deck, :card

    def initialize(deck:, card:)
      super()
      self.deck = deck
      self.card = card
    end

    def view_template
      div(class: "music-study", data: root_data) do
        render_card_head
        render_status
        render_progress
        render_controls
        render_form
      end
    end

    private

    def root_data
      { controller: "music-study", music_study_sequence_value: card.back }
    end

    def render_card_head
      div(class: "music-study__head") do
        h2(class: "music-study__placeholder") { "?" }
        p(class: "music-study__hint") { "Listen, then play it back" }
      end
    end

    def render_status
      p(class: "music-study__status", data: { music_study_target: "status" }) do
        "Press Start Microphone to begin"
      end
    end

    def render_progress
      p(
        class: "music-study__progress",
        data: { music_study_target: "progress" },
      )
    end

    def render_controls
      div(class: "music-study__controls") do
        render_start_button
        render_play_button
      end
    end

    def render_start_button
      button(
        type: "button",
        class: "button button--primary",
        data: {
          music_study_target: "startButton",
          action: "click->music-study#startMic",
        },
      ) { "Start Microphone" }
    end

    def render_play_button
      button(
        type: "button",
        class: "button button--secondary",
        hidden: true,
        data: play_button_data,
      ) { "▶ Play Reference" }
    end

    def play_button_data
      {
        music_study_target: "playButton",
        action: "click->music-study#play",
      }
    end

    def render_form
      form_with(
        url: deck_study_path(deck),
        method: :patch,
        data: form_data,
      ) do |form|
        render_form_fields(form)
      end
    end

    def render_form_fields(form)
      form.hidden_field("answer[card_id]", value: card.id)
      form.hidden_field(
        "answer[answer]",
        data: { music_study_target: "answerInput" },
      )
    end

    def form_data
      { music_study_target: "form", turbo_frame: "study" }
    end
  end
end
