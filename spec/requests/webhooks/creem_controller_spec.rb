# frozen_string_literal: true

RSpec.describe Webhooks::CreemController do
  def sign_payload(json_body)
    OpenSSL::HMAC
      .hexdigest("sha256", ENV.fetch("CREEM_WEBHOOK_SECRET"), json_body)
  end

  def webhook_headers(payload)
    signature = sign_payload(payload.to_json)
    { "CONTENT_TYPE" => "application/json", "creem-signature" => signature }
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

  def failed_payload(subscription)
    {
      type: "subscription.payment_failed",
      data: { id: subscription.creem_subscription_id },
    }
  end

  def canceled_payload(subscription)
    {
      type: "subscription.canceled",
      data: { id: subscription.creem_subscription_id },
    }
  end

  describe "#create" do
    describe "signature verification" do
      it "returns 404 for invalid signature" do
        payload = { type: "subscription.created", data: {} }
        headers = webhook_headers(payload).merge("creem-signature" => "x")

        post(webhooks_creem_path, params: payload.to_json, headers:)

        expect(response).to have_http_status(:not_found)
      end

      it "raises KeyError for missing signature header" do
        payload = { type: "subscription.created", data: {} }
        headers = { "CONTENT_TYPE" => "application/json" }

        expect { post(webhooks_creem_path, params: payload.to_json, headers:) }
          .to raise_error(KeyError)
      end

      it "returns 200 for valid signature" do
        payload = { type: "unknown.event", data: {} }
        headers = webhook_headers(payload)

        post(webhooks_creem_path, params: payload.to_json, headers:)

        expect(response).to have_http_status(:ok)
      end
    end

    describe "subscription.created" do
      it "creates a subscription for existing user" do
        payload = created_payload(default_user)
        headers = webhook_headers(payload)

        expect { post(webhooks_creem_path, params: payload.to_json, headers:) }
          .to change(Subscription, :count).by(1)
      end

      it "sets the creem subscription id" do
        data = subscription_data(email: default_user.email, id: "sub_xyz789")
        payload = { type: "subscription.created", data: }
        headers = webhook_headers(payload)

        post(webhooks_creem_path, params: payload.to_json, headers:)

        expect(Subscription.last.creem_subscription_id).to eq("sub_xyz789")
      end

      it "sets the status" do
        payload = created_payload(default_user)
        headers = webhook_headers(payload)

        post(webhooks_creem_path, params: payload.to_json, headers:)

        expect(Subscription.last.status).to eq("active")
      end

      it "sets the plan name" do
        payload = created_payload(default_user)
        headers = webhook_headers(payload)

        post(webhooks_creem_path, params: payload.to_json, headers:)

        expect(Subscription.last.plan_name).to eq("Monthly")
      end

      it "sets the period start" do
        payload = created_payload(default_user)
        headers = webhook_headers(payload)

        post(webhooks_creem_path, params: payload.to_json, headers:)

        expect(Subscription.last.current_period_start).to be_present
      end

      it "associates subscription with user" do
        payload = created_payload(default_user)
        headers = webhook_headers(payload)

        post(webhooks_creem_path, params: payload.to_json, headers:)

        expect(Subscription.last.user).to eq(default_user)
      end

      it "returns 404 when user not found" do
        data = subscription_data(email: "nonexistent@example.com")
        payload = { type: "subscription.created", data: }
        headers = webhook_headers(payload)

        post(webhooks_creem_path, params: payload.to_json, headers:)

        expect(response).to have_http_status(:not_found)
      end

      it "returns 200 on success" do
        payload = created_payload(default_user)
        headers = webhook_headers(payload)

        post(webhooks_creem_path, params: payload.to_json, headers:)

        expect(response).to have_http_status(:ok)
      end
    end

    describe "subscription.updated" do
      it "updates the subscription period end" do
        subscription = create(:subscription, current_period_end: 1.day.from_now)
        payload = updated_payload(subscription)
        headers = webhook_headers(payload)

        expect { post(webhooks_creem_path, params: payload.to_json, headers:) }
          .to change_record(subscription, :current_period_end)
      end

      it "updates the subscription status" do
        subscription = create(:subscription, status: "active")
        payload = updated_payload(subscription, status: "trialing")
        headers = webhook_headers(payload)

        expect { post(webhooks_creem_path, params: payload.to_json, headers:) }
          .to change_record(subscription, :status).to("trialing")
      end

      it "returns 200 when subscription not found" do
        subscription = Subscription.new(creem_subscription_id: "x")
        payload = updated_payload(subscription)
        headers = webhook_headers(payload)

        post(webhooks_creem_path, params: payload.to_json, headers:)

        expect(response).to have_http_status(:ok)
      end

      it "does not create a subscription when not found" do
        payload = updated_payload(Subscription.new(creem_subscription_id: "x"))
        headers = webhook_headers(payload)

        expect { post(webhooks_creem_path, params: payload.to_json, headers:) }
          .not_to(change(Subscription, :count))
      end
    end

    describe "subscription.canceled" do
      it "sets subscription status to canceled" do
        subscription = create(:subscription, status: "active")
        payload = canceled_payload(subscription)
        headers = webhook_headers(payload)

        expect { post(webhooks_creem_path, params: payload.to_json, headers:) }
          .to change_record(subscription, :status).to("canceled")
      end

      it "returns 200 when subscription not found" do
        payload = { type: "subscription.canceled", data: { id: "sub_x" } }
        headers = webhook_headers(payload)

        post(webhooks_creem_path, params: payload.to_json, headers:)

        expect(response).to have_http_status(:ok)
      end

      it "does not raise error when subscription not found" do
        payload = { type: "subscription.canceled", data: { id: "sub_x" } }
        headers = webhook_headers(payload)

        expect { post(webhooks_creem_path, params: payload.to_json, headers:) }
          .not_to raise_error
      end
    end

    describe "subscription.payment_failed" do
      it "sets subscription status to past_due" do
        subscription = create(:subscription, status: "active")
        payload = failed_payload(subscription)
        headers = webhook_headers(payload)

        expect { post(webhooks_creem_path, params: payload.to_json, headers:) }
          .to change_record(subscription, :status).to("past_due")
      end

      it "returns 200 when subscription not found" do
        payload = { type: "subscription.payment_failed", data: { id: "sub_x" } }
        headers = webhook_headers(payload)

        post(webhooks_creem_path, params: payload.to_json, headers:)

        expect(response).to have_http_status(:ok)
      end

      it "does not raise error when subscription not found" do
        payload = { type: "subscription.payment_failed", data: { id: "sub_x" } }
        headers = webhook_headers(payload)

        expect { post(webhooks_creem_path, params: payload.to_json, headers:) }
          .not_to raise_error
      end
    end

    describe "unknown event type" do
      it "returns 200 for unknown event types" do
        payload = { type: "charge.succeeded", data: { id: "ch_123" } }
        headers = webhook_headers(payload)

        post(webhooks_creem_path, params: payload.to_json, headers:)

        expect(response).to have_http_status(:ok)
      end

      it "does not create or modify any subscriptions" do
        create(:subscription)
        payload = { type: "charge.succeeded", data: { id: "ch_123" } }
        headers = webhook_headers(payload)

        expect { post(webhooks_creem_path, params: payload.to_json, headers:) }
          .not_to(change(Subscription, :count))
      end
    end
  end
end
