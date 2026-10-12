# frozen_string_literal: true

module Views
  module Sources
    class Index < Views::Base
      HEADINGS = ["Title", "Author", "Status", ""].freeze

      attr_accessor :sources

      def initialize(sources:)
        super()
        self.sources = sources
      end

      def view_template
        h1 { "Sources" }

        link_to("Add a source", new_source_path, class: button_class(:primary))

        sources.none? ? p { "No sources yet" } : render_table
      end

      private

      def render_table
        sources_table = Components::Table.new(headings: HEADINGS, rows: sources)

        render(sources_table) do |table, source|
          table.cell { link_to(source.title, source_path(source)) }
          table.cell { source.author }
          table.cell { Show::STATUSES[source.status] }
          table.cell { render_study_button(source) if source.studyable? }
        end
      end

      def render_study_button(source)
        button_to(
          "Study this list",
          source_deck_path(source),
          method: :post,
          class: button_class(:secondary, :compact),
        )
      end
    end
  end
end
