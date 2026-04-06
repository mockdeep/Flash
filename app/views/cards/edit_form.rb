# frozen_string_literal: true

module Views
  module Cards
    class EditForm < Components::Base
      def initialize(deck:, card:)
        super()
        @deck = deck
        @card = card
      end

      def view_template
        turbo_frame_tag("card_edit_form") do
          render_errors if @card.errors.any?
          render_form
        end
      end

      private

      def render_errors
        div(class: "error-explanation") do
          div(class: "error-icon") { "⚠" }
          render_error_content
        end
      end

      def render_error_content
        div(class: "error-content") do
          count = @card.errors.count
          h2 { "#{pluralize(count, "problem")} with your card:" }
          ul do
            @card.errors.full_messages.each do |msg|
              li { msg }
            end
          end
        end
      end

      def render_form
        form_with(
          model: [@deck, @card],
          data: {
            action: "turbo:submit-end->dialog#closeOnSuccess",
          },
        ) do |f|
          render_fields(f)
          render_actions(f)
        end
      end

      def render_fields(form)
        div(class: "edit-card__fields") do
          text_area_field(form, :front, "Front")
          text_area_field(form, :back, "Back")
          text_field(form, :category, "Category")
        end
      end

      def text_area_field(form, attr, label)
        div(class: "form-field") do
          form.label(attr, label, class: "form-label")
          form.text_area(attr, class: "form-input", rows: 3)
        end
      end

      def text_field(form, attr, label)
        div(class: "form-field") do
          form.label(attr, label, class: "form-label")
          form.text_field(attr, class: "form-input")
        end
      end

      def render_actions(form)
        div(class: "edit-card__actions") do
          button(
            type: "button",
            class: button_class(:ghost, :compact),
            data: { action: "click->dialog#close" },
          ) { "Cancel" }
          form.submit("Save", class: button_class(:primary, :compact))
        end
      end
    end
  end
end
