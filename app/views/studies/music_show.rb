# frozen_string_literal: true

module Views
  module Studies
    class MusicShow < Views::Base
      include StudyFrameData

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
          render_header
          h1 { deck.name }
          turbo_frame_tag("study", data: wake_lock_data) do
            render_frame
          end
        end
      end

      private

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
        if deck.cards.none?
          render_empty
        else
          render(progress_component)
          render_card_or_milestone
        end
      end

      def progress_component
        Components::SessionProgress.new(deck:, completed:, study_goal:)
      end

      def empty_body
        "This deck doesn't have any cards yet."
      end

      def render_card_or_milestone
        if completed >= study_goal
          render(Components::SessionMilestone.new(deck:, study_goal:, demo:))
        else
          render(Components::MusicCardBody.new(deck:, cards: study.next_window))
        end
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
