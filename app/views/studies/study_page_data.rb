# frozen_string_literal: true

module Views
  module Studies
    # Wired on the page around the study frame and the Read tab, so the text
    # size and font reach both.
    module StudyPageData
      def study_page_data
        data = mix(text_size_data, wake_lock_data)
        return data unless deck.mandarin?

        mix(data, font_data)
      end

      # Outside the study frame, so they work on the Read tab too.
      def render_text_size_hotkeys
        span(hidden: true, data: text_size_hotkey_data("[", "smaller"))
        span(hidden: true, data: text_size_hotkey_data("]", "larger"))
      end

      def text_size_hotkey_data(key, action)
        {
          hotkeys_target: "click",
          hotkey: key,
          action: "click->text-size##{action}",
        }
      end

      def text_size_data
        {
          controller: "text-size",
          text_size_deck_id_value: deck.id,
          size: "m",
        }
      end

      def wake_lock_data
        {
          controller: "wake-lock",
          action: "visibilitychange@document->wake-lock#refresh",
        }
      end

      def font_data
        {
          controller: "font",
          font_deck_id_value: deck.id,
        }
      end

      # Turbo frame navigation keeps only the frame's contents, so the hanzi
      # prewarm payload only rides on full page loads, not on the frame
      # navigation that fetches each next card.
      def study_page_data_with_hanzi
        data = study_page_data
        return data if turbo_frame_request? || !deck.mandarin?

        data.merge(font_hanzi_value: deck.hanzi_chars)
      end
    end
  end
end
