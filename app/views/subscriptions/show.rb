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

        if subscription.blank?
          render_no_subscription
        else
          render_subscription_details
        end
      end

      private

      def render_no_subscription
        p { "You don't have an active subscription." }

        form_with(url: subscription_path, method: :post) do |form|
          form.submit("Subscribe Now")
        end
      end

      def render_subscription_details
        div do
          h2 { "Current Subscription" }

          dl do
            dt { "Status" }
            dd { subscription.status.titleize }

            dt { "Plan" }
            dd { subscription.plan_name }

            if subscription.current_period_end
              dt { "Next billing date" }
              dd { subscription.current_period_end.strftime("%B %d, %Y") }
            end

            if subscription.canceled_at
              dt { "Canceled on" }
              dd { subscription.canceled_at.strftime("%B %d, %Y") }
            end
          end

          if subscription.active?
            form_with(url: subscription_path, method: :delete) do
              submit("Cancel Subscription", data: { confirm: "Are you sure you want to cancel your subscription?" })
            end
          end
        end
      end
    end
  end
end
