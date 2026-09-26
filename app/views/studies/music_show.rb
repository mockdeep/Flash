# frozen_string_literal: true

module Views
  module Studies
    class MusicShow < Views::Base
      include StudyFrameData

      attr_accessor :deck, :study, :demo

      def initialize(deck:, study:, demo: false)
        super()
        self.deck = deck
        self.study = study
        self.demo = demo
      end

      def view_template
        div(class: "content-container") do
          render_header
          h1 { deck.name }
          turbo_frame_tag("study", data: wake_lock_data) do
            render_frame
          end
        end
      end

      private

      def render_level_progress
        div(class: "session-progress") do
          render(Components::LevelProgress.new(deck:))
        end
      end

      def render_header
        if demo
          render(Components::DemoBanner.new)
        else
          link_to("View Deck", deck_path(deck))
          plain(" | ")
          link_to("All Decks", decks_path)
        end
      end

      def render_frame
        if deck.cards_count.zero?
          render_empty
        else
          render_level_progress
          render(Components::MusicCardBody.new(deck:, cards: study.next_window))
        end
      end

      def empty_body
        "This deck doesn't have any cards yet."
      end

      def render_empty
        div(class: "accent-box") do
          div(class: "accent-box__icon") { "📚" }
          div(class: "accent-box__content") do
            h2(class: "accent-box__heading") { "No cards to study" }
            p(class: "accent-box__text") { empty_body }
          end
        end
        link_to("All Decks", decks_path, class: "button button--primary")
      end
    end
  end
end
