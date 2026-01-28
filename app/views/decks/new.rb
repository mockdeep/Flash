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
            link_to("← Back to Decks", decks_path, class: "form-back-link")
            h1(class: "form-title") { "Create New Deck" }
            p(class: "form-subtitle") do
              "Upload a CSV file with your flashcards to get started learning."
            end
          end

          div(class: "form-card") do
            form_with(model: deck, class: "deck-form") do |form|
              errors = deck.errors
              if errors.any?
                div(class: "error-explanation") do
                  div(class: "error-icon") { "⚠" }
                  div(class: "error-content") do
                    h2 { "#{pluralize(errors.count, "problem")} with your deck:" }
                    ul do
                      errors.full_messages.each do |message|
                        li { message }
                      end
                    end
                  end
                end
              end

              div(class: "form-field") do
                form.label(:name, "Deck Name", class: "form-label")
                form.text_field(:name, required: true, class: "form-input", placeholder: "e.g., Spanish Vocabulary, Chemistry Formulas")
              end

              div(class: "form-field") do
                form.label(:cards_csv, "Flashcards CSV File", class: "form-label")

                div(class: "csv-instructions") do
                  div(class: "csv-instructions-header") do
                    span(class: "csv-icon") { "📄" }
                    strong { "CSV Format Requirements" }
                  end
                  ul(class: "csv-requirements") do
                    li { "Columns: front, back, and category" }
                    li { "Use ';' to separate multiple back answers" }
                    li do
                      plain("Need an example? Download a sample ")
                      link_options = { target: "_blank", rel: "noopener", class: "csv-sample-link" }
                      link_to("Spanish CSV file here", csv_url, **link_options)
                    end
                  end
                end

                div(class: "file-upload-wrapper") do
                  form.file_field(:cards_csv, required: true, class: "file-input", accept: ".csv")
                  div(class: "file-upload-label") do
                    span(class: "upload-icon") { "📤" }
                    span(class: "upload-text") { "Choose CSV file or drag here" }
                  end
                end
              end

              div(class: "form-actions") do
                link_to("Cancel", decks_path, class: "btn-cancel")
                form.submit("Create Deck", class: "btn-submit")
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
