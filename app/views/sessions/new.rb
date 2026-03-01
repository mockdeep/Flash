# frozen_string_literal: true

module Views
  module Sessions
    class New < Views::Base
      def view_template
        div(class: "auth-container") do
          div(class: "auth-icon") do
            div(class: "auth-icon-box") do
              span(class: "auth-icon-symbol") { "⚡" }
            end
          end

          h1(class: "auth-title") { "Welcome Back" }
          p(class: "auth-subtitle") { "Log in to continue studying" }

          div(class: "auth-card") do
            form_with(scope: :session, url: session_path, class: "auth-form") do |form|
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
                  placeholder: "Enter your password",
                )
              end

              div(class: "auth-actions") do
                form.submit("Log In", class: button_class(:primary))
              end
            end

            div(class: "auth-footer") do
              p(class: "auth-footer-text") do
                plain("Don't have an account? ")
                link_to("Sign up", new_account_path, class: "auth-footer-link")
              end
            end
          end
        end
      end
    end
  end
end
