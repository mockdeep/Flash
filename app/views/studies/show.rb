# frozen_string_literal: true

module Views
  module Studies
    class Show < Views::Base
      attr_accessor :deck, :study

      def initialize(deck:, study:)
        super()
        self.deck = deck
        self.study = study
      end

      def view_template
        link_to("Back to Decks", decks_path)

        h1 { deck.name }

        card = study.next_card

        turbo_frame_tag("study") do
          progress(value: deck.cards.done.count, max: deck.cards.count)

          h2 { card.front }

          ol do
            study.possible_answers.each_with_index do |answer, index|
              li do
                params = { answer: { answer:, card_id: card.id } }
                path = deck_study_path(deck)
                data = { hotkeys_target: "click", hotkey: (index + 1).to_s }
                button_to(path, data:, params:, method: :patch) { answer }
              end
            end
          end
        end

        link_to("Back to Decks", decks_path)
      end
    end
  end
end
