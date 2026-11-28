# frozen_string_literal: true

module Views
  module Studies
    class Show < Views::Base
      include StudyPageData

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
        div(
          class: "content-container study-page",
          data: study_page_data_with_hanzi,
        ) do
          render_header

          render(Components::StudyTabs.new) if reading?

          turbo_frame_tag("study", class: "study-frame") do
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
            render(Components::PracticeLabel.new) if study.practice?

            if goal_reached?
              render(Components::SessionMilestone.new(deck:, study_goal:, demo:))
            elsif study.next_card.nil?
              render_nothing_left
            else
              card = study.next_card

              p(class: "study-level") { level_text }
              render(
                Components::CardFront.new(
                  text: card.front,
                  deck:,
                  reading: study.prompt_reading,
                  card_id: card.id,
                ),
              )

              render(Components::StudyAnswers.new(deck:, study:))

              # Claim the space hotkey to prevent scrolling down
              span(data: { hotkeys_target: "click", hotkey: " " }, hidden: true)
            end
          end

          render_reading if reading?
          render_text_size_hotkeys
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

        h1 { with_translation(deck.name, deck.name_translation) }
      end

      def goal_reached? = !deck.no_goal? && completed >= study_goal

      # On a deck over a text, how far into it study has reached.
      def level_text
        place = StudyPlace.new(deck).page
        level = "Level #{study.level}"
        place ? "#{level} · Studying up to page #{place}" : level
      end

      def render_nothing_left
        if deck.all_done?
          render(Components::DeckFinished.new(deck:, demo:))
        else
          render(Components::ComeBackTomorrow.new(deck:, demo:))
        end
      end

      # Turbo keeps only the study frame from a frame request, so the text
      # is left out of it.
      def reading?
        !turbo_frame_request? && pages.any?
      end

      def pages = @pages ||= ReadingPages.for(deck)

      # The page the reader left off on, if the deck's text holds it.
      def render_reading
        place = current_user.reading_places.find_by(source: deck.source)
        page = pages.at(place&.snippet_sentence_id, place&.token_index)
        render(Components::SnippetReading.new(deck:, pages:, page:))
      end
    end
  end
end
