# frozen_string_literal: true

module Views
  module Cards
    class EditForm < Components::Base
      FORM_ID = "card_edit_form_form"

      def initialize(deck:, card:)
        super()
        @deck = deck
        @card = card
      end

      def view_template
        turbo_frame_tag("card_edit_form") do
          render(Components::ErrorExplanation.new(errors: @card.errors))
          render_form
          render_actions
        end
      end

      private

      def render_form
        data = { action: "turbo:submit-end->dialog#closeOnSuccess" }
        form_with(model: [@deck, @card], id: FORM_ID, data:) do |f|
          render_fields(f)
        end
      end

      def render_fields(form)
        div(class: "edit-card__fields") do
          text_area_field(form, @card, :front, "Front", autofocus: true)
          text_area_field(form, @card, :back, "Back")
          text_field(form, @card, :reading, "Reading")
          text_field(form, @card, :category, "Category")
          text_area_field(form, @card, :example_front, "Example")
          text_area_field(form, @card, :example_back, "Example translation")
        end
      end

      def text_area_field(form, content, attr, label, autofocus: false)
        value = content.public_send(attr)
        div(class: "form-field") do
          form.label(attr, label, class: "form-label")
          form.text_area(attr, value:, class: "form-input", rows: 3, autofocus:)
        end
      end

      def text_field(form, content, attr, label)
        value = content.public_send(attr)
        div(class: "form-field") do
          form.label(attr, label, class: "form-label")
          form.text_field(attr, value:, class: "form-input")
        end
      end

      def render_actions
        div(class: "edit-card__actions") do
          render_delete_button
          div(class: "edit-card__actions-group") do
            render_cancel_button
            render_save_button
          end
        end
      end

      def render_delete_button
        button_to(
          "Delete",
          deck_card_path(@deck, @card),
          method: :delete,
          class: button_class(:danger, :compact),
          form: { data: delete_form_data },
        )
      end

      def delete_form_data
        { turbo_frame: "study", turbo_confirm: t("cards.destroy.confirm") }
      end

      def render_cancel_button
        button(
          type: "button",
          class: button_class(:ghost, :compact),
          data: { action: "click->dialog#close" },
        ) { "Cancel" }
      end

      def render_save_button
        button(
          type: "submit",
          form: FORM_ID,
          class: button_class(:primary, :compact),
          data: { hotkeys_target: "click", hotkey: "ctrl+Enter" },
        ) { "Save" }
      end
    end
  end
end
