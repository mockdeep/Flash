# frozen_string_literal: true

module Views
  module Subscriptions
    class Show < Views::Base
      attr_accessor :subscription

      def initialize(subscription:)
        super()
        self.subscription = subscription
      end

      def view_template
        h1 { "Subscription" }

        if subscription&.active?
          render_active_subscription
        else
          render_no_subscription
        end
      end

      private

      def render_active_subscription
        div(class: "subscription-details") do
          h2 { "You're subscribed!" }

          p { "Your subscription is active and gives you access to all premium features." }

          dl do
            dt { "Status" }
            dd { subscription.status.titleize }

            if subscription.expires_at
              dt { "Renews on" }
              dd { subscription.expires_at.strftime("%B %d, %Y") }
            end
          end

          div(class: "actions") do
            button_to(
              "Cancel Subscription",
              cancel_subscription_path(subscription),
              method: :post,
              data: { confirm: "Are you sure you want to cancel your subscription?" },
              class: "button button-danger"
            )
          end
        end
      end

      def render_no_subscription
        div(class: "no-subscription") do
          p { "You don't have an active subscription." }
          p { "Subscribe to unlock premium features!" }

          div(class: "actions") do
            a(href: new_subscription_path, class: "button button-primary") do
              "Subscribe Now"
            end
          end
        end
      end
    end
  end
end
