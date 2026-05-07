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
          h1 do
            plain("My Account")
            supporter_badge if user.supporter?
          end

          render_form
          button_to("Delete Account", account_path, method: :delete)
        end
      end

      private

      def render_form
        form_with(model: user, url: account_path) do |form|
          render(Components::ErrorExplanation.new(errors: user.errors))
          render_fields(form)
          render_actions(form)
        end
      end

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
    end
  end
end
