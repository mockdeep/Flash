# frozen_string_literal: true

class PolarWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_webhook_signature

  def create
    event_type = webhook_params[:type]
    payload = webhook_params[:data]

    case event_type
    when "subscription.created"
      handle_subscription_created(payload)
    when "subscription.updated"
      handle_subscription_updated(payload)
    when "subscription.canceled", "subscription.cancelled"
      handle_subscription_canceled(payload)
    when "subscription.revoked"
      handle_subscription_revoked(payload)
    else
      Rails.logger.info("Unhandled webhook event type: #{event_type}")
    end

    head :ok
  rescue StandardError => e
    Rails.logger.error("Webhook processing error: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    head :unprocessable_entity
  end

  private

  def webhook_params
    params.permit!.to_h.deep_symbolize_keys
  end

  def verify_webhook_signature
    signature = request.headers["Webhook-Signature"]
    timestamp = request.headers["Webhook-Timestamp"]

    unless signature && timestamp
      Rails.logger.error("Missing webhook signature or timestamp")
      head :unauthorized
      return
    end

    # Get the raw request body for signature verification
    payload = request.raw_post
    webhook_secret = ENV.fetch("POLAR_WEBHOOK_SECRET", nil)

    unless webhook_secret
      Rails.logger.error("POLAR_WEBHOOK_SECRET not configured")
      head :internal_server_error
      return
    end

    # Verify the signature using HMAC-SHA256
    expected_signature = OpenSSL::HMAC.hexdigest(
      "SHA256",
      webhook_secret,
      "#{timestamp}.#{payload}"
    )

    # Compare using secure comparison to prevent timing attacks
    unless ActiveSupport::SecurityUtils.secure_compare(signature, expected_signature)
      Rails.logger.error("Invalid webhook signature")
      head :unauthorized
    end
  end

  def handle_subscription_created(payload)
    user = find_user_by_polar_customer(payload)
    return unless user

    # Avoid creating duplicate subscriptions
    existing = Subscription.find_by(polar_subscription_id: payload[:id])
    if existing
      Rails.logger.info("Subscription already exists: #{payload[:id]}")
      return
    end

    Subscription.create!(
      user: user,
      polar_subscription_id: payload[:id],
      status: payload[:status],
      tier: payload.dig(:product, :name) || "default",
      expires_at: parse_timestamp(payload[:current_period_end])
    )

    Rails.logger.info("Subscription created for user #{user.id}: #{payload[:id]}")
  end

  def handle_subscription_updated(payload)
    subscription = Subscription.find_by(polar_subscription_id: payload[:id])
    return unless subscription

    subscription.update!(
      status: payload[:status],
      expires_at: parse_timestamp(payload[:current_period_end])
    )

    Rails.logger.info("Subscription updated: #{payload[:id]}")
  end

  def handle_subscription_canceled(payload)
    subscription = Subscription.find_by(polar_subscription_id: payload[:id])
    return unless subscription

    subscription.cancel!

    Rails.logger.info("Subscription canceled: #{payload[:id]}")
  end

  def handle_subscription_revoked(payload)
    subscription = Subscription.find_by(polar_subscription_id: payload[:id])
    return unless subscription

    subscription.update!(status: "revoked")

    Rails.logger.info("Subscription revoked: #{payload[:id]}")
  end

  def find_user_by_polar_customer(payload)
    customer_email = payload.dig(:user, :email) || payload.dig(:customer, :email)
    return nil unless customer_email

    User.find_by(email: customer_email)
  end

  def parse_timestamp(timestamp)
    return nil unless timestamp

    Time.zone.parse(timestamp)
  rescue ArgumentError
    nil
  end
end
