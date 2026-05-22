# frozen_string_literal: true

module Views
  module Studies
    module TextSizeData
      def text_size_data
        {
          controller: "text-size",
          text_size_deck_id_value: deck.id,
          size: "m",
          action:
            "click@window->text-size#handleDocClick " \
            "keydown@window->text-size#handleEsc",
        }
      end
    end
  end
end
