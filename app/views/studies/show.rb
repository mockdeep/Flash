# frozen_string_literal: true

module Views
  module Studies
    class Show < Views::Base
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
          if demo
            render(Components::DemoBanner.new)
          else
            link_to("View Deck", deck_path(deck))
            plain(" | ")
            link_to("All Decks", decks_path)
          end

          h1 { deck.name }

          render(Components::StudyTabs.new) if reading?

          turbo_frame_tag(
            "study",
            class: "study-frame",
            data: study_frame_data_with_hanzi,
          ) do
            if deck.cards_count.zero?
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

            if goal_reached?
              render(Components::SessionMilestone.new(deck:, study_goal:, demo:))
            else
              card = study.next_card

              render(
                Components::CardFront.new(
                  text: card.front,
                  reading: study.prompt_reading,
                  font_menu: deck.mandarin?,
                  card_id: card.id,
                ),
              )

              render(Components::StudyAnswers.new(deck:, study:))

              # Claim the space hotkey to prevent scrolling down
              span(data: { hotkeys_target: "click", hotkey: " " }, hidden: true)
            end
          end

          render(Components::SnippetReading.new(snippets:)) if reading?
        end
      end

      private

      def goal_reached? = !deck.no_goal? && completed >= study_goal

      # Admin-only until snippets have a way to be shared. Turbo keeps only
      # the study frame from a frame request, so the text is left out of it.
      def reading?
        !turbo_frame_request? && current_user.admin? && snippets.any?
      end

      def snippets = deck.snippets
    end
  end
end
