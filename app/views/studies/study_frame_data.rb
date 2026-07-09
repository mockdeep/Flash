# frozen_string_literal: true

module Views
  module Studies
    module StudyFrameData
      def study_frame_data
        data = {
          controller: "text-size",
          text_size_deck_id_value: deck.id,
          size: "m",
        }
        return data unless deck.mandarin?

        data.merge(font_frame_data)
      end

      def font_frame_data
        {
          controller: "text-size font",
          font_deck_id_value: deck.id,
        }
      end

      # Turbo frame swaps keep the original frame element's attributes, so the
      # hanzi prewarm payload only rides on full page loads, not on the frame
      # navigation that fetches each next card.
      def study_frame_data_with_hanzi
        data = study_frame_data
        return data if turbo_frame_request? || !deck.mandarin?

        data.merge(font_hanzi_value: deck.hanzi_chars)
      end
    end
  end
end
