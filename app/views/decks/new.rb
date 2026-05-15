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
                    plain(" Text / Flashcard")
                  end
                  label(class: "deck-type-option") do
                    form.radio_button(:deck_type, "music", data: { deck_type_target: "radio", action: "change->deck-type#update" })
                    plain(" Music (microphone required)")
                  end
                end

                fieldset(class: "form-field deck-type-toggle", data: { deck_type_target: "musicSettings" }, hidden: true) do
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

                  div(class: "csv-instructions", data: { deck_type_target: "textInstructions" }) do
                    div(class: "csv-instructions-header") do
                      span(class: "csv-icon") { "📄" }
                      strong { "CSV Format Requirements" }
                    end
                    ul(class: "csv-requirements") do
                      li { "Required columns: front, back, and category" }
                      li { "Optional column: distractors" }
                      li { "Use ';' to separate multiple back answers or distractors" }
                      li do
                        plain("Need an example? Download a sample ")
                        link_options = { target: "_blank", rel: "noopener", class: "csv-sample-link" }
                        link_to("Spanish CSV file here", csv_url, **link_options)
                      end
                    end
                  end

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

      def csv_url
        ENV.fetch("SAMPLE_CSV_URL", nil)
      end
    end
  end
end
