# frozen_string_literal: true

module Webhooks
  class CreemController < ApplicationController
    skip_before_action(:authenticate_user)
    skip_before_action(:verify_authenticity_token)

    def create
      verify_signature!

      event_type = webhook_params[:type]
      event_data = webhook_params[:data]

      case event_type
      when "subscription.created"
        handle_subscription_created(event_data)
      when "subscription.updated"
        handle_subscription_updated(event_data)
      when "subscription.canceled"
        handle_subscription_canceled(event_data)
      when "subscription.payment_failed"
        handle_payment_failed(event_data)
      else
        Rails.logger.info("Unhandled Creem webhook event: #{event_type}")
      end

      head(:ok)
    end

    private

    def verify_signature!
      signature = request.headers.fetch("creem-signature")
      payload = request.raw_post

      expected_signature = OpenSSL::HMAC.hexdigest(
        "sha256",
        ENV.fetch("CREEM_WEBHOOK_SECRET"),
        payload
      )

      unless ActiveSupport::SecurityUtils.secure_compare(signature, expected_signature)
        Rails.logger.warn("Invalid Creem webhook signature")
        raise ActionController::RoutingError, 'Not Found'
      end
    end

    def handle_subscription_created(data)
      user = User.find_by!(email: data[:customer][:email])

      user.create_subscription!(
        creem_subscription_id: data[:id],
        status: data[:status],
        current_period_start: Time.zone.at(data[:current_period_start]),
        current_period_end: Time.zone.at(data[:current_period_end]),
        plan_name: data[:plan][:name],
      )
    end

    def handle_subscription_updated(data)
      subscription = Subscription.find_by(creem_subscription_id: data[:id])
      return unless subscription

      subscription.update!(
        status: data[:status],
        current_period_start: Time.zone.at(data[:current_period_start]),
        current_period_end: Time.zone.at(data[:current_period_end]),
      )
    end

    def handle_subscription_canceled(data)
      subscription = Subscription.find_by(creem_subscription_id: data[:id])
      return unless subscription

      subscription.update!(status: "canceled")
    end

    def handle_payment_failed(data)
      subscription = Subscription.find_by(creem_subscription_id: data[:id])
      return unless subscription

      subscription.update!(status: "past_due")
    end

    def webhook_params
      params.permit!.to_h.deep_symbolize_keys
    end
  end
end
