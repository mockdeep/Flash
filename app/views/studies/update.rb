# frozen_string_literal: true

module Views
  module Studies
    class Update < Views::Base
      attr_accessor :deck, :result

      def initialize(deck:, result:)
        super()
        self.deck = deck
        self.result = result
      end

      def view_template
        turbo_frame_tag("study") do
          done_count = deck.cards.done.count
          cards_count = deck.cards.count
          progress(value: done_count, max: cards_count)
          plain("#{done_count} / #{cards_count} cards done")

          if result.correct?
            p { "Correct! 🎉" }
          else
            p { "Incorrect. The correct answer was: #{result.correct_answer}" }
          end

          data = { hotkeys_target: "click", hotkey: " " }
          link_to("Next Card", deck_study_path(deck), data:)
        end
      end
    end
  end
end
