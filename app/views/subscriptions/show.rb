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
        div(class: "card subscription-card") do
          div(class: "subscription-pricing") do
            div(class: "price-display") do
              span(class: "price-display__currency") { "$" }
              span(class: "price-display__value") { "5" }
              span(class: "price-display__period") { "/month" }
            end
          end

          div(class: "accent-box subscription-notice") do
            div(class: "accent-box__icon") { "💛" }
            div(class: "accent-box__content") do
              h3(class: "accent-box__heading") { "Support Flash" }
              p(class: "accent-box__text") do
                <<~TEXT
                  Subscribers get a supporter heart that appears next to their
                  username throughout Flash. The bigger reason to subscribe is to
                  help cover hosting costs and keep the project running, which
                  is greatly appreciated!
                TEXT
              end
            end
          end

          div(class: "subscription-status") do
            div(class: "status-icon") { "📭" }
            p(class: "status-text") { "You don't have an active subscription." }
          end

          form_with(url: subscription_path, method: :post, class: "subscription-form") do |form|
            form.submit("Subscribe for $5/month", class: button_class(:primary))
          end
        end
      end

      def render_subscription_details
        div(class: "card subscription-card") do
          if subscription.active?
            div(class: "subscription-badge") do
              span(class: "subscription-badge-icon") { "✓" }
              span(class: "subscription-badge-text") { "Active Subscriber" }
            end
          else
            div(class: "subscription-badge subscription-badge--canceled") do
              span(class: "subscription-badge-icon") { "✗" }
              span(class: "subscription-badge-text") { "Subscription #{subscription.status.titleize}" }
            end
          end

          h2(class: "subscription-subtitle") { "Current Subscription" }

          dl(class: "subscription-details") do
            dt { "Status" }
            dd(class: "detail-value") { subscription.status.titleize }

            dt { "Plan" }
            dd(class: "detail-value") { subscription.plan_name }

            if subscription.active? && subscription.current_period_end
              dt { "Next billing date" }
              dd(class: "detail-value") { subscription.current_period_end.strftime("%B %d, %Y") }
            end
          end

          if subscription.active?
            form_with(url: subscription_path, method: :delete, class: "subscription-form") do |form|
              form.submit("Cancel Subscription", class: button_class(:danger), data: { confirm: "Are you sure you want to cancel your subscription?" })
            end
          else
            form_with(url: subscription_path, method: :post, class: "subscription-form") do |form|
              form.submit("Resubscribe for $5/month", class: button_class(:primary))
            end
          end
        end
      end
    end
  end
end
