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
        return data unless deck.hanzi?

        data.merge(font_frame_data)
      end

      def font_frame_data
        {
          controller: "text-size font",
          font_deck_id_value: deck.id,
        }
      end
    end
  end
end
