# frozen_string_literal: true

module Views
  module Accounts
    class Show < Views::Base
      attr_accessor :user

      def initialize(user:)
        super()
        self.user = user
      end

      def view_template
        div(class: "form-container") do
          h1 { "My Account" }

          form_with(model: user, url: account_path) do |form|
            error_explanation
            render_fields(form)
            render_actions(form)
          end

          button_to("Delete Account", account_path, method: :delete)
        end
      end

      private

      def render_fields(form)
        div(class: "form-field") do
          form.label(:username, class: "form-label")
          form.text_field(:username, required: true, class: "form-input")
        end

        div(class: "form-field") do
          form.label(:email, class: "form-label")
          form.email_field(:email, required: true, class: "form-input")
        end

        div(class: "form-field") do
          form.label(:study_goal, "Default Study Goal", class: "form-label")
          form.number_field(
            :study_goal,
            min: 1,
            required: true,
            class: "form-input",
          )
        end
      end

      def render_actions(form)
        div(class: "actions") do
          form.submit("Update Account", class: button_class(:primary))
        end
      end

      def error_explanation
        errors = user.errors
        return if errors.none?

        div(class: "error-explanation") do
          div(class: "error-icon") { "\u26A0" }
          div(class: "error-content") do
            h2 do
              "#{pluralize(errors.count, "problem")} with your account:"
            end
            ul do
              errors.full_messages.each do |message|
                li { message }
              end
            end
          end
        end
      end
    end
  end
end
