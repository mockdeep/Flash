# frozen_string_literal: true

module Views
  module Snippets
    class Index < Views::Base
      HEADINGS = ["Title", "Author", "List", "Status", ""].freeze
      STATUSES = {
        new: "New",
        in_progress: "In progress",
        finished: "Finished",
      }.freeze

      attr_accessor :snippets

      def initialize(snippets:)
        super()
        self.snippets = snippets
      end

      def view_template
        h1 { "Snippets" }

        link_to(
          "Add a snippet",
          new_snippet_path,
          class: button_class(:primary),
        )

        snippets.none? ? p { "No snippets yet" } : render_table
      end

      private

      def render_table
        snippets_table =
          Components::Table.new(headings: HEADINGS, rows: snippets)

        render(snippets_table) do |table, snippet|
          table.cell { snippet.title }
          table.cell { snippet.author }
          table.cell { snippet.word_list.name }
          table.cell { STATUSES[snippet.status] }
          table.cell { render_study_button(snippet) }
        end
      end

      # A list only gains senses as its snippets are finished, so an
      # unfinished one has nothing yet to study.
      def render_study_button(snippet)
        return unless snippet.status == :finished

        button_to(
          "Study this list",
          snippet_deck_path(snippet),
          method: :post,
          class: button_class(:secondary, :compact),
        )
      end
    end
  end
end
