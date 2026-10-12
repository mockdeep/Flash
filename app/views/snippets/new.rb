# frozen_string_literal: true

module Views
  module Snippets
    class New < Views::Base
      attr_accessor :snippet

      def initialize(snippet:)
        super()
        self.snippet = snippet
      end

      def view_template
        div(class: "form-container") do
          render_header
          div(class: "card card--striped form-card") { render_form }
        end
      end

      private

      def source = snippet.source

      def render_header
        div(class: "form-header") do
          render_back_link
          h1(class: "form-title") { "Add a Snippet" }
          p(class: "form-subtitle") do
            "Paste a Chinese snippet and its words join #{source.title}'s list"
          end
        end
      end

      def render_back_link
        text = "← Back to #{source.title}"
        link_to(text, source_path(source), class: "back-link")
      end

      def render_form
        url = source_snippets_path(source)

        form_with(url:, scope: :snippet, class: "deck-form") do |form|
          render(Components::ErrorExplanation.new(errors: snippet.errors))

          render_heading_field(form)
          render_body_field(form)
          render_actions(form)
        end
      end

      def render_heading_field(form)
        div(class: "form-field") do
          form.label(:heading, "Heading (optional)", class: "form-label")
          form.text_field(:heading, value: snippet.heading, class: "form-input")
        end
      end

      def render_body_field(form)
        options = { value: snippet.body, rows: 12, lang: "zh" }

        div(class: "form-field") do
          form.label(:body, "Text", class: "form-label")
          form.text_area(:body, required: true, class: "form-input", **options)
        end
      end

      def render_actions(form)
        div(class: "form-actions") do
          link_to("Cancel", source_path(source), class: button_class(:ghost))
          form.submit("Add Snippet", class: button_class(:primary))
        end
      end
    end
  end
end
