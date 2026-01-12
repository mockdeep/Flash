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
        div(class: "subscription-container") do
          h1(class: "subscription-title") { "Subscription" }

          if subscription.blank?
            render_no_subscription
          else
            render_subscription_details
          end
        end
      end

      private

      def render_no_subscription
        div(class: "subscription-card") do
          div(class: "subscription-pricing") do
            div(class: "pricing-amount") do
              span(class: "pricing-currency") { "$" }
              span(class: "pricing-value") { "5" }
              span(class: "pricing-period") { "/month" }
            end
          end

          div(class: "subscription-notice") do
            div(class: "notice-icon") { "💛" }
            div(class: "notice-content") do
              h3(class: "notice-heading") { "Support Flash" }
              p do
                <<~TEXT
                  There are currently no extra benefits or features included with a
                  subscription. However, if you'd like to show your support for the
                  project and help with hosting costs, a subscription is greatly
                  appreciated!
                TEXT
              end
            end
          end

          div(class: "subscription-status") do
            div(class: "status-icon") { "📭" }
            p(class: "status-text") { "You don't have an active subscription." }
          end

          form_with(url: subscription_path, method: :post, class: "subscription-form") do |form|
            form.submit("Subscribe for $5/month", class: "subscription-button")
          end
        end
      end

      def render_subscription_details
        div(class: "subscription-card") do
          div(class: "subscription-active-badge") do
            span(class: "badge-icon") { "✓" }
            span(class: "badge-text") { "Active Subscriber" }
          end

          h2(class: "subscription-subtitle") { "Current Subscription" }

          dl(class: "subscription-details") do
            dt { "Status" }
            dd(class: "detail-value") { subscription.status.titleize }

            dt { "Plan" }
            dd(class: "detail-value") { subscription.plan_name }

            if subscription.current_period_end
              dt { "Next billing date" }
              dd(class: "detail-value") { subscription.current_period_end.strftime("%B %d, %Y") }
            end

            if subscription.canceled_at
              dt { "Canceled on" }
              dd(class: "detail-value") { subscription.canceled_at.strftime("%B %d, %Y") }
            end
          end

          if subscription.active?
            form_with(url: subscription_path, method: :delete, class: "subscription-form") do
              submit("Cancel Subscription", class: "subscription-button subscription-button-danger", data: { confirm: "Are you sure you want to cancel your subscription?" })
            end
          end
        end
      end
    end
  end
end
