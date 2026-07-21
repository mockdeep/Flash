# frozen_string_literal: true

module Components
  class ReplaceCardsDialog < Components::Base
    def view_template
      dialog(class: "dialog", data: dialog_data) do
        render_header
        render_body
      end
    end

    private

    def dialog_data
      {
        confirm_dialog_target: "dialog",
        action: "click->confirm-dialog#closeOnBackdropClick",
      }
    end

    def render_header
      div(class: "dialog__header") do
        h2(class: "dialog__title") { "Confirm replacement" }
        button(
          type: "button",
          class: "dialog__close",
          data: { action: "click->confirm-dialog#close" },
        ) { "✕" }
      end
    end

    def render_body
      div(class: "dialog__body") do
        p { message }
        render_actions
      end
    end

    def message
      "Cards removed from the CSV will be deleted, and cards with a " \
        "changed answer will reset to zero progress."
    end

    def render_actions
      div(class: "edit-card__actions") do
        action_button("Cancel", :ghost, "close")
        action_button("Yes, Replace Cards", :primary, "confirm")
      end
    end

    def action_button(label, style, action)
      button(
        type: "button",
        class: button_class(style, :compact),
        data: { action: "click->confirm-dialog##{action}" },
      ) { label }
    end
  end
end
