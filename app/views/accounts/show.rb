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
          errors = user.errors
          if errors.any?
            div(class: "error-explanation") do
              h2 { "#{pluralize(errors.count, "problem")} with your signup:" }
              ul do
                errors.full_messages.each do |message|
                  li { message }
                end
              end
            end
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
    end
  end
end
