# frozen_string_literal: true

module Views
  module Accounts
    class Remove < Views::Base
      attr_accessor :user

      def initialize(user:)
        super()
        self.user = user
      end

      def view_template
        div(class: "form-container") do
          h1 { "Delete Account" }

          p do
            plain("This will permanently delete the account for ")
            strong { user.username }
            plain(", along with its decks and study progress.")
          end

          p { strong { "This cannot be undone" } }

          render_actions
        end
      end

      private

      def render_actions
        div(class: "actions") do
          button_to(
            "Permanently Delete Account",
            account_path,
            method: :delete,
            class: button_class(:danger),
          )
          link_to("Cancel", account_path, class: button_class(:ghost))
        end
      end
    end
  end
end
