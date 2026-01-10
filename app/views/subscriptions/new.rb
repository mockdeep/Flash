# frozen_string_literal: true

module Views
  module Subscriptions
    class New < Views::Base
      def view_template
        h1 { "Subscribe" }

        div(class: "subscription-info") do
          p { "Get access to premium features with a subscription." }

          ul do
            li { "Unlimited decks and flashcards" }
            li { "Advanced study features" }
            li { "Priority support" }
            li { "Cancel anytime" }
          end
        end

        div(class: "actions") do
          button_to("Subscribe Now", subscription_path, class: "button button-primary")
        end

        div(class: "back-link") do
          a(href: subscription_path) { "← Back to Subscriptions" }
        end
      end
    end
  end
end
