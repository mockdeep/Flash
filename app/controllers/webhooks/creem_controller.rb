# frozen_string_literal: true

module Webhooks
  class CreemController < ApplicationController
    skip_before_action(:authenticate_user)
    skip_before_action(:verify_authenticity_token)

    def create
      verify_signature!

      event_type = webhook_params.fetch(:eventType)
      object = webhook_params.fetch(:object)

      unless event_type.start_with?("subscription.")
        raise ArgumentError, "wrong event type: #{event_type.inspect}"
      end

      update_subscription(object)

      head(:ok)
    end

    private

    def verify_signature!
      signature = request.headers.fetch("creem-signature")
      payload = request.raw_post

      expected_signature = OpenSSL::HMAC.hexdigest(
        "sha256",
        ENV.fetch("CREEM_WEBHOOK_SECRET"),
        payload,
      )

      unless ActiveSupport::SecurityUtils.secure_compare(signature, expected_signature)
        raise ActionController::RoutingError, "Not Found"
      end
    end

    def update_subscription(object)
      user = User.find_by!(email: object[:customer][:email])
      subscription = user.subscription || user.build_subscription

      subscription.update!(
        creem_subscription_id: object.fetch(:id),
        status: object.fetch(:status),
        current_period_start: Time.zone.parse(object.fetch(:current_period_start_date)),
        current_period_end: Time.zone.parse(object.fetch(:current_period_end_date)),
        plan_name: object.fetch(:product).fetch(:name),
      )
    end

    def webhook_params
      object = [
        :id,
        :status,
        :current_period_start_date,
        :current_period_end_date,
        { product: [:name] },
        { customer: [:email] },
      ]
      params.permit(:eventType, object:, creem: [:eventType, { object: }])
        .to_h.deep_symbolize_keys
    end
  end
end
