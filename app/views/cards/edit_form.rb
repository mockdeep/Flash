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
          render(Components::ErrorExplanation.new(errors: @card.errors))
          render_form
        end
      end

      private

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
          text_area_field(form, :front, "Front", autofocus: true)
          text_area_field(form, :back, "Back")
          text_field(form, :category, "Category")
        end
      end

      def text_area_field(form, attr, label, autofocus: false)
        div(class: "form-field") do
          form.label(attr, label, class: "form-label")
          form.text_area(attr, class: "form-input", rows: 3, autofocus:)
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
          submit_class = button_class(:primary, :compact)
          submit_data = { hotkeys_target: "click", hotkey: "ctrl+Enter" }
          form.submit("Save", class: submit_class, data: submit_data)
        end
      end
    end
  end
end
