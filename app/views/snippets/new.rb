# frozen_string_literal: true

module Views
  module Snippets
    class New < Views::Base
      attr_accessor :snippet, :list_names

      def initialize(snippet:, list_names:)
        super()
        self.snippet = snippet
        self.list_names = list_names
      end

      def view_template
        div(class: "form-container") do
          render_header
          div(class: "card card--striped form-card") { render_form }
        end
      end

      private

      def render_header
        div(class: "form-header") do
          link_to("← Back to Snippets", snippets_path, class: "back-link")
          h1(class: "form-title") { "Add a Snippet" }
          p(class: "form-subtitle") do
            "Paste a Chinese snippet and its words join the list you name"
          end
        end
      end

      def render_form
        options = { url: snippets_path, scope: :snippet, class: "deck-form" }

        form_with(**options) do |form|
          render(Components::ErrorExplanation.new(errors: snippet.errors))

          render_field(form, :title, "Title", required: true)
          render_field(form, :author, "Author")
          render_list_field(form)
          render_body_field(form)
          render_actions(form)
        end
      end

      def render_field(form, name, label, **)
        div(class: "form-field") do
          form.label(name, label, class: "form-label")
          form.text_field(name, value: snippet[name], class: "form-input", **)
        end
      end

      def render_list_field(form)
        value = snippet.word_list&.name
        options = { value:, list: "snippet-list-names", class: "form-input" }

        div(class: "form-field") do
          form.label(:list_name, "Word List", class: "form-label")
          form.text_field(:list_name, required: true, **options)
          datalist(id: "snippet-list-names") do
            list_names.each { |name| option(value: name) }
          end
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
          link_to("Cancel", snippets_path, class: button_class(:ghost))
          form.submit("Add Snippet", class: button_class(:primary))
        end
      end
    end
  end
end
