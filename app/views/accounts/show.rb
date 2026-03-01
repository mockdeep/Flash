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
        h1 { "My Account" }

        form_with(model: user, url: account_path) do |form|
          error_explanation

          div(class: "field") do
            form.label(:username)
            form.text_field(:username, required: true)
          end

          div(class: "field") do
            form.label(:email)
            form.email_field(:email, required: true)
          end

          div(class: "actions") do
            form.submit("Update Account")
          end
        end

        button_to("Delete Account", account_path, method: :delete)
      end

      private

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
