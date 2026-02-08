# frozen_string_literal: true

module Views
  module Accounts
    class New < Views::Base
      attr_accessor :user

      def initialize(user:)
        super()
        self.user = user
      end

      def view_template
        div(class: "auth-container") do
          div(class: "auth-icon") do
            div(class: "auth-icon-box") do
              span(class: "auth-icon-symbol") { "✦" }
            end
          end

          h1(class: "auth-title") { "Create Your Account" }
          p(class: "auth-subtitle") { "Start mastering any subject today" }

          div(class: "auth-card") do
            render_errors

            form_with(model: user, url: account_path, class: "auth-form") do |form|
              div(class: "auth-form-field") do
                form.label(:username, "Username", class: "auth-label")
                form.text_field(
                  :username,
                  required: true,
                  class: "auth-input",
                  placeholder: "your_username",
                )
              end

              div(class: "auth-form-field") do
                form.label(:email, "Email", class: "auth-label")
                form.email_field(
                  :email,
                  required: true,
                  class: "auth-input",
                  placeholder: "you@example.com",
                )
              end

              div(class: "auth-form-field") do
                form.label(:password, "Password", class: "auth-label")
                form.password_field(
                  :password,
                  required: true,
                  class: "auth-input",
                  placeholder: "Create a password",
                )
              end

              div(class: "auth-form-field") do
                form.label(:password_confirmation, "Confirm Password", class: "auth-label")
                form.password_field(
                  :password_confirmation,
                  required: true,
                  class: "auth-input",
                  placeholder: "Confirm your password",
                )
              end

              div(class: "auth-actions") do
                form.submit("Create Account", class: "auth-submit")
              end
            end

            div(class: "auth-footer") do
              p(class: "auth-footer-text") do
                plain("Already have an account? ")
                link_to("Log in", new_session_path, class: "auth-footer-link")
              end
            end
          end
        end
      end

      private

      def render_errors
        errors = user.errors
        return if errors.none?

        div(class: "auth-error") do
          div(class: "auth-error-icon") { "⚠" }
          div(class: "auth-error-content") do
            h2(class: "auth-error-heading") do
              "#{pluralize(errors.count, "problem")} with your signup:"
            end
            ul(class: "auth-error-list") do
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
