# frozen_string_literal: true

module Views
  module Decks
    module Replacements
      class New < Views::Base
        attr_accessor :deck

        def initialize(deck:)
          super()
          self.deck = deck
        end

        def view_template
          div(class: "form-container") do
            render_header
            render_form
          end
        end

        private

        def render_header
          div(class: "form-header") do
            link_to("← Back to Deck", deck_path(deck), class: "back-link")
            h1(class: "form-title") { "Replace cards in #{deck.name}" }
            p(class: "form-subtitle") { subtitle }
          end
        end

        def subtitle
          "Upload a new CSV. Cards with the same front keep their progress; " \
            "cards whose back has changed are reset."
        end

        def render_form
          div(class: "card card--striped form-card") do
            form_with(
              url: deck_replacement_path(deck),
              scope: :replacement,
              class: "deck-form",
              data: confirm_data,
            ) { |form| render_form_body(form) }
          end
        end

        def confirm_data
          {
            controller: "confirm-submit",
            confirm_submit_message_value: confirm_message,
            action: "submit->confirm-submit#confirm",
          }
        end

        def confirm_message
          "Replace cards? Cards removed from the CSV will be deleted, and " \
            "cards with a changed answer will reset to zero progress."
        end

        def render_form_body(form)
          render(Components::ErrorExplanation.new(errors: deck.errors))
          render_csv_field(form)
          render_actions(form)
        end

        def render_csv_field(form)
          div(class: "form-field") do
            form.label(:cards_csv, "Flashcards CSV File", class: "form-label")
            render(Components::TextCsvInstructions.new)
            render_file_input(form)
          end
        end

        def render_file_input(form)
          wrapper_data = { controller: "file-upload" }
          div(class: "file-upload-wrapper", data: wrapper_data) do
            render_file_field(form)
            render_file_label
          end
        end

        def render_file_field(form)
          form.file_field(
            :cards_csv,
            required: true,
            class: "file-input",
            accept: ".csv",
            data: file_input_data,
          )
        end

        def file_input_data
          { file_upload_target: "input", action: "file-upload#select" }
        end

        def render_file_label
          div(class: "file-upload-label") do
            span(class: "upload-icon", data: { file_upload_target: "icon" }) do
              "📤"
            end
            span(class: "upload-text", data: { file_upload_target: "text" }) do
              "Choose CSV file or drag here"
            end
          end
        end

        def render_actions(form)
          div(class: "form-actions") do
            link_to("Cancel", deck_path(deck), class: button_class(:ghost))
            form.submit("Replace Cards", class: button_class(:primary))
          end
        end
      end
    end
  end
end
