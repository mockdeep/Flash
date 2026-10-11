# frozen_string_literal: true

module Views
  module SnippetReaders
    class Index < Views::Base
      HEADINGS = ["Reader", ""].freeze

      attr_accessor :snippet, :reader

      def initialize(snippet:, reader:)
        super()
        self.snippet = snippet
        self.reader = reader
      end

      def view_template
        div(class: "form-container") do
          render_header
          div(class: "card card--striped form-card") do
            render_readers
            render_form
          end
        end
      end

      private

      def render_header
        div(class: "form-header") do
          link_to("← Back to Snippets", snippets_path, class: "back-link")
          h1(class: "form-title") { "Share #{snippet.title}" }
          p(class: "form-subtitle") do
            <<~TEXT
              Readers can read this snippet whatever its license. Adding one
              also adds a deck over its word list to their account.
            TEXT
          end
        end
      end

      def render_form
        options = { url: snippet_readers_path(snippet), scope: :reader }

        form_with(**options, class: "deck-form") do |form|
          render(Components::ErrorExplanation.new(errors: reader.errors))
          render_username_field(form)

          div(class: "form-actions") do
            form.submit("Add Reader", class: button_class(:primary))
          end
        end
      end

      def render_username_field(form)
        div(class: "form-field") do
          form.label(:username, "Add a reader", class: "form-label")
          form.text_field(:username, required: true, class: "form-input")
        end
      end

      def render_readers
        readers = snippet.readers.sort_by { |reader| reader.user.username }
        return p(class: "form-subtitle") { "No readers yet" } if readers.none?

        readers_table = Components::Table.new(headings: HEADINGS, rows: readers)

        render(readers_table) do |table, reader|
          table.cell { reader.user.username }
          table.cell { render_remove_button(reader) }
        end
      end

      def render_remove_button(reader)
        button_to(
          "Remove",
          snippet_reader_path(snippet, reader),
          method: :delete,
          class: button_class(:ghost, :compact),
        )
      end
    end
  end
end
