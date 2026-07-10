# frozen_string_literal: true

module Views
  module Decks
    class New < Views::Base
      attr_accessor :deck

      def initialize(deck:)
        super()
        self.deck = deck
      end

      def view_template
        div(class: "form-container") do
          div(class: "form-header") do
            link_to("← Back to Decks", decks_path, class: "back-link")
            h1(class: "form-title") { "Create New Deck" }
            p(class: "form-subtitle") do
              "Upload a CSV file with your flashcards to get started learning."
            end
          end

          div(class: "card card--striped form-card") do
            form_with(model: deck, class: "deck-form") do |form|
              render(Components::ErrorExplanation.new(errors: deck.errors))

              div(class: "form-field") do
                form.label(:name, "Deck Name", class: "form-label")
                form.text_field(:name, required: true, class: "form-input", placeholder: "e.g., Spanish Vocabulary, Chemistry Formulas")
              end

              div(data: { controller: "deck-type" }) do
                fieldset(class: "form-field deck-type-toggle") do
                  legend(class: "form-label") { "Deck Type" }
                  label(class: "deck-type-option") do
                    form.radio_button(:deck_type, "text", checked: true, data: { deck_type_target: "radio", action: "change->deck-type#update" })
                    plain(" Basic")
                  end
                  label(class: "deck-type-option") do
                    form.radio_button(:deck_type, "language", data: { deck_type_target: "radio", action: "change->deck-type#update" })
                    plain(" Language")
                  end
                  label(class: "deck-type-option") do
                    form.radio_button(:deck_type, "music", data: { deck_type_target: "radio", action: "change->deck-type#update" })
                    plain(" Music (microphone required)")
                  end
                end

                fieldset(class: "form-field deck-type-toggle", data: { deck_type_target: "languageSettings" }, hidden: true, disabled: true) do
                  form.label(:language, "Language", class: "form-label")
                  form.select(
                    :language,
                    language_options,
                    { prompt: "Select a language" },
                    required: true,
                    class: "form-input",
                  )
                end

                fieldset(class: "form-field deck-type-toggle", data: { deck_type_target: "musicSettings" }, hidden: true, disabled: true) do
                  legend(class: "form-label") { "Music Style" }
                  label(class: "deck-type-option") do
                    form.radio_button(:ordered, "true", checked: true)
                    plain(" Ordered melody or scale")
                  end
                  label(class: "deck-type-option") do
                    form.radio_button(:ordered, "false")
                    plain(" Unordered note pool")
                  end
                end

                div(class: "form-field") do
                  form.label(:cards_csv, "Flashcards CSV File", class: "form-label")

                  instructions_data = { deck_type_target: "textInstructions" }
                  render(Components::TextCsvInstructions.new(data: instructions_data))

                  render(Components::MusicCsvInstructions.new)

                  div(class: "file-upload-wrapper", data: { controller: "file-upload" }) do
                    form.file_field(:cards_csv, required: true, class: "file-input", accept: ".csv", data: { file_upload_target: "input", action: "file-upload#select" })
                    div(class: "file-upload-label") do
                      span(class: "upload-icon", data: { file_upload_target: "icon" }) { "📤" }
                      span(class: "upload-text", data: { file_upload_target: "text" }) { "Choose CSV file or drag here" }
                    end
                  end
                end
              end

              div(class: "form-actions") do
                link_to("Cancel", decks_path, class: button_class(:ghost))
                form.submit("Create Deck", class: button_class(:primary))
              end
            end
          end
        end
      end

      private

      # Optgroups: the common languages up top, everything else below.
      # A code appears in only one group so option text stays unambiguous.
      def language_options
        common = DataSet::COMMON_LANGUAGE_CODES
        {
          "Common" => DataSet::LANGUAGES.slice(*common).map(&:reverse).sort,
          "More languages" =>
            DataSet::LANGUAGES.except(*common).map(&:reverse),
        }
      end
    end
  end
end
