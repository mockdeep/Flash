# frozen_string_literal: true

module Views
  module Sources
    class New < Views::Base
      attr_accessor :source

      def initialize(source:)
        super()
        self.source = source
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
          link_to("← Back to Sources", sources_path, class: "back-link")
          h1(class: "form-title") { "Add a Source" }
          p(class: "form-subtitle") do
            "An article, a book, or a drawer of scraps. Its snippets' words " \
              "fill a word list of the same name"
          end
        end
      end

      def render_form
        options = { url: sources_path, scope: :source, class: "deck-form" }

        form_with(**options) do |form|
          render(Components::ErrorExplanation.new(errors: source.errors))

          render_field(form, :title, "Title", required: true)
          render_language_field(form)
          render_field(form, :author, "Author")
          render_field(form, :source_url, "Source URL", type: "url")
          render_license_field(form)
          render_actions(form)
        end
      end

      def render_field(form, name, label, **)
        div(class: "form-field") do
          form.label(name, label, class: "form-label")
          form.text_field(name, value: source[name], class: "form-input", **)
        end
      end

      def render_language_field(form)
        languages = Language::ALL.keys.map { [WordList::LANGUAGES[it], it] }

        div(class: "form-field") do
          form.label(:language, "Language", class: "form-label")
          form.select(
            :language,
            languages,
            { selected: source.word_list&.language },
            class: "form-input",
          )
        end
      end

      def render_license_field(form)
        licenses = Source::LICENSES.map { |key, license| [license[:name], key] }

        div(class: "form-field") do
          form.label(:license, "License", class: "form-label")
          form.select(
            :license,
            licenses,
            { selected: source.license },
            class: "form-input",
          )
        end
      end

      def render_actions(form)
        div(class: "form-actions") do
          link_to("Cancel", sources_path, class: button_class(:ghost))
          form.submit("Add Source", class: button_class(:primary))
        end
      end
    end
  end
end
