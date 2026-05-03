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
        li { "Octaves are strict; only sharps are supported (no flats)" }
      end
    end

    def render_field_items
      li do
        strong { "front" }
        plain(": a label revealed after the user gets it right ")
        plain('(e.g., "A3 Note", "C Major Chord")')
      end
      li do
        strong { "back" }
        plain(': comma-separated notes (e.g., A3 or "C4,E4,G4")')
      end
      li { "Wrap multi-note backs in quotes so commas don't split the cell" }
    end
  end
end
