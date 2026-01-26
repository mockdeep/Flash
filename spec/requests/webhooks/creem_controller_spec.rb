# frozen_string_literal: true

require "rails_helper"

RSpec.describe Webhooks::CreemController do
  def sign_payload(json_body)
    OpenSSL::HMAC.hexdigest(
      "sha256",
      ENV.fetch("CREEM_WEBHOOK_SECRET"),
      json_body,
    )
  end

  def post_webhook(payload, signature: nil)
    json_body = payload.to_json
    signature ||= sign_payload(json_body)
    post(
      webhooks_creem_path,
      params: json_body,
      headers: {
        "CONTENT_TYPE" => "application/json",
        "creem-signature" => signature,
      },
    )
  end

  def subscription_data(email:, id: "sub_123", status: "active")
    {
      id:,
      status:,
      current_period_start: Time.current.to_i,
      current_period_end: 30.days.from_now.to_i,
      plan: { name: "Monthly" },
      customer: { email: },
    }
  end

  def created_payload(user)
    { type: "subscription.created", data: subscription_data(email: user.email) }
  end

  def updated_payload(subscription, status: "active")
    {
      type: "subscription.updated",
      data: {
        id: subscription.creem_subscription_id,
        status:,
        current_period_start: Time.current.to_i,
        current_period_end: 30.days.from_now.to_i,
      },
    }
  end

  def canceled_payload(subscription_id)
    { type: "subscription.canceled", data: { id: subscription_id } }
  end

  def payment_failed_payload(subscription_id)
    { type: "subscription.payment_failed", data: { id: subscription_id } }
  end

  def post_without_signature(payload)
    post(
      webhooks_creem_path,
      params: payload.to_json,
      headers: { "CONTENT_TYPE" => "application/json" },
    )
  end

  describe "#create" do
    describe "signature verification" do
      it "returns 404 for invalid signature" do
        post_webhook({ type: "subscription.created", data: {} }, signature: "x")

        expect(response).to have_http_status(:not_found)
      end

      it "raises KeyError for missing signature header" do
        payload = { type: "subscription.created", data: {} }

        expect { post_without_signature(payload) }.to raise_error(KeyError)
      end

      it "returns 200 for valid signature" do
        post_webhook({ type: "unknown.event", data: {} })

        expect(response).to have_http_status(:ok)
      end
    end

    describe "subscription.created" do
      it "creates a subscription for existing user" do
        payload = created_payload(default_user)

        expect { post_webhook(payload) }.to change(Subscription, :count).by(1)
      end

      it "sets the creem subscription id" do
        data = subscription_data(email: default_user.email, id: "sub_xyz789")
        post_webhook({ type: "subscription.created", data: })

        expect(Subscription.last.creem_subscription_id).to eq("sub_xyz789")
      end

      it "sets the status" do
        post_webhook(created_payload(default_user))

        expect(Subscription.last.status).to eq("active")
      end

      it "sets the plan name" do
        post_webhook(created_payload(default_user))

        expect(Subscription.last.plan_name).to eq("Monthly")
      end

      it "sets the period start" do
        post_webhook(created_payload(default_user))

        expect(Subscription.last.current_period_start).to be_present
      end

      it "associates subscription with user" do
        post_webhook(created_payload(default_user))

        expect(Subscription.last.user).to eq(default_user)
      end

      it "returns 404 when user not found" do
        data = subscription_data(email: "nonexistent@example.com")
        post_webhook({ type: "subscription.created", data: })

        expect(response).to have_http_status(:not_found)
      end

      it "returns 200 on success" do
        post_webhook(created_payload(default_user))

        expect(response).to have_http_status(:ok)
      end
    end

    describe "subscription.updated" do
      it "updates the subscription period end" do
        subscription = create(:subscription, current_period_end: 1.day.from_now)
        payload = updated_payload(subscription)

        expect { post_webhook(payload) }
          .to change_record(subscription, :current_period_end)
      end

      it "updates the subscription status" do
        subscription = create(:subscription, status: "active")
        payload = updated_payload(subscription, status: "trialing")

        expect { post_webhook(payload) }
          .to change_record(subscription, :status).to("trialing")
      end

      it "returns 200 when subscription not found" do
        sub = Subscription.new(creem_subscription_id: "x")
        post_webhook(updated_payload(sub))

        expect(response).to have_http_status(:ok)
      end

      it "does not create a subscription when not found" do
        payload = updated_payload(Subscription.new(creem_subscription_id: "x"))

        expect { post_webhook(payload) }.not_to(change(Subscription, :count))
      end
    end

    describe "subscription.canceled" do
      it "sets subscription status to canceled" do
        subscription = create(:subscription, status: "active")
        payload = canceled_payload(subscription.creem_subscription_id)

        expect { post_webhook(payload) }
          .to change_record(subscription, :status).to("canceled")
      end

      it "returns 200 when subscription not found" do
        post_webhook(canceled_payload("sub_nonexistent"))

        expect(response).to have_http_status(:ok)
      end

      it "does not raise error when subscription not found" do
        payload = canceled_payload("sub_nonexistent")

        expect { post_webhook(payload) }.not_to raise_error
      end
    end

    describe "subscription.payment_failed" do
      it "sets subscription status to past_due" do
        subscription = create(:subscription, status: "active")
        payload = payment_failed_payload(subscription.creem_subscription_id)

        expect { post_webhook(payload) }
          .to change_record(subscription, :status).to("past_due")
      end

      it "returns 200 when subscription not found" do
        post_webhook(payment_failed_payload("sub_nonexistent"))

        expect(response).to have_http_status(:ok)
      end

      it "does not raise error when subscription not found" do
        payload = payment_failed_payload("sub_nonexistent")

        expect { post_webhook(payload) }.not_to raise_error
      end
    end

    describe "unknown event type" do
      it "returns 200 for unknown event types" do
        post_webhook({ type: "charge.succeeded", data: { id: "ch_123" } })

        expect(response).to have_http_status(:ok)
      end

      it "does not create or modify any subscriptions" do
        create(:subscription)
        payload = { type: "charge.succeeded", data: { id: "ch_123" } }

        expect { post_webhook(payload) }.not_to(change(Subscription, :count))
      end
    end
  end
end
