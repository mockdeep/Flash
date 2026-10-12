# frozen_string_literal: true

module Views
  module Sources
    class Show < Views::Base
      HEADINGS = ["Heading", "Status"].freeze
      STATUSES = {
        new: "New",
        in_progress: "In progress",
        finished: "Finished",
      }.freeze

      attr_accessor :source

      def initialize(source:)
        super()
        self.source = source
      end

      def view_template
        link_to("← Back to Sources", sources_path, class: "back-link")
        h1 { source.title }
        render_details

        div(class: "table__actions") do
          render_add_button
          render_finished_actions if source.studyable?
        end

        source.snippets.none? ? p { "No snippets yet" } : render_table
      end

      private

      def render_details
        p { source.author } if source.author.present?
        p { render(Components::SourceCredit.new(source:)) }
      end

      def render_add_button
        link_to(
          "Add a snippet",
          new_source_snippet_path(source),
          class: button_class(:primary),
        )
      end

      # Only a finished snippet has anything to study or read.
      def render_finished_actions
        button_to(
          "Study this list",
          source_deck_path(source),
          method: :post,
          class: button_class(:secondary),
        )
        share_path = source_readers_path(source)
        link_to("Share", share_path, class: button_class(:ghost))
      end

      def render_table
        snippets_table =
          Components::Table.new(headings: HEADINGS, rows: source.snippets)

        render(snippets_table) do |table, snippet|
          table.cell { snippet.heading }
          table.cell { STATUSES[snippet.status] }
        end
      end
    end
  end
end
