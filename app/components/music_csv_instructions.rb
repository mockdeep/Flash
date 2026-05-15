# frozen_string_literal: true

module Components
  class MusicCsvInstructions < Components::Base
    def view_template
      div(
        class: "csv-instructions",
        data: { deck_type_target: "musicInstructions" },
        hidden: true,
      ) do
        render_header
        render_requirements
      end
    end

    private

    def render_header
      div(class: "csv-instructions-header") do
        span(class: "csv-icon") { "🎵" }
        strong { "Music CSV Format" }
      end
    end

    def render_requirements
      ul(class: "csv-requirements") do
        li { "Required columns: front, back" }
        li { "Optional column: category" }
        render_field_items
        li { "One note per row; octaves are strict, only sharps (no flats)" }
        li do
          plain("For ordered melodies and scales, ")
          plain("row order in the CSV defines the sequence.")
        end
      end
    end

    def render_field_items
      li do
        strong { "front" }
        plain(": a label revealed after the user gets it right ")
        plain('(e.g., "A3 Note", "Open E string")')
      end
      li do
        strong { "back" }
        plain(": a single note (e.g., A3, C#4)")
      end
    end
  end
end
