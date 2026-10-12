# frozen_string_literal: true

module Views
  module Sources
    class Show < Views::Base
      HEADINGS = ["Heading", "Status", ""].freeze
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
          render_study_button if source.studyable?
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

      def render_study_button
        button_to(
          "Study this list",
          source_deck_path(source),
          method: :post,
          class: button_class(:secondary),
        )
      end

      def render_table
        snippets_table =
          Components::Table.new(headings: HEADINGS, rows: source.snippets)

        render(snippets_table) do |table, snippet|
          table.cell { snippet.heading }
          table.cell { STATUSES[snippet.status] }
          table.cell { render_share_link(snippet) }
        end
      end

      # Only a finished snippet has anything to read.
      def render_share_link(snippet)
        return unless snippet.status == :finished

        link_to(
          "Share",
          snippet_readers_path(snippet),
          class: button_class(:ghost, :compact),
        )
      end
    end
  end
end
