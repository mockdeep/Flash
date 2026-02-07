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

  def subscription_object(email:, id: "sub_123", status: "active")
    {
      id:,
      status:,
      current_period_start_date: Time.current.iso8601,
      current_period_end_date: 30.days.from_now.iso8601,
      product: { name: "Monthly" },
      customer: { email: },
    }
  end

  def created_payload(user)
    {
      eventType: "subscription.active",
      object: subscription_object(email: user.email),
    }
  end

  def updated_payload(subscription, status: "active")
    {
      eventType: "subscription.paid",
      object: subscription_object(
        email: subscription.user.email,
        id: subscription.creem_subscription_id,
        status:,
      ),
    }
  end

  describe "#create" do
    describe "signature verification" do
      it "returns 404 for invalid signature" do
        payload = { eventType: "subscription.active", object: {} }
        headers = webhook_headers(payload).merge("creem-signature" => "x")

        post(webhooks_creem_path, params: payload.to_json, headers:)

        expect(response).to have_http_status(:not_found)
      end

      it "raises KeyError for missing signature header" do
        payload = { eventType: "subscription.active", object: {} }
        headers = { "CONTENT_TYPE" => "application/json" }

        expect { post(webhooks_creem_path, params: payload.to_json, headers:) }
          .to raise_error(KeyError)
      end

      it "returns 200 for valid signature" do
        payload = updated_payload(create(:subscription))
        headers = webhook_headers(payload)

        post(webhooks_creem_path, params: payload.to_json, headers:)

        expect(response).to have_http_status(:ok)
      end
    end

    describe "subscription.active" do
      it "creates a subscription for existing user" do
        payload = created_payload(default_user)
        headers = webhook_headers(payload)

        expect { post(webhooks_creem_path, params: payload.to_json, headers:) }
          .to change(Subscription, :count).by(1)
      end

      it "sets the creem subscription id" do
        object = subscription_object(email: default_user.email, id: "sub_xyz67")
        payload = { eventType: "subscription.active", object: }
        headers = webhook_headers(payload)

        post(webhooks_creem_path, params: payload.to_json, headers:)

        expect(Subscription.last.creem_subscription_id).to eq("sub_xyz67")
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
        object = subscription_object(email: "nonexistent@example.com")
        payload = { eventType: "subscription.active", object: }
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

    describe "subscription.paid" do
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

      it "returns 404 when user not found" do
        object = subscription_object(email: "nonexistent@example.com")
        payload = { eventType: "subscription.paid", object: }
        headers = webhook_headers(payload)

        post(webhooks_creem_path, params: payload.to_json, headers:)

        expect(response).to have_http_status(:not_found)
      end

      it "does not create a subscription when user not found" do
        object = subscription_object(email: "nonexistent@example.com")
        payload = { eventType: "subscription.paid", object: }
        headers = webhook_headers(payload)

        expect { post(webhooks_creem_path, params: payload.to_json, headers:) }
          .not_to(change(Subscription, :count))
      end
    end

    describe "subscription.canceled" do
      it "sets subscription status to canceled" do
        subscription = create(:subscription, status: "active")
        payload = updated_payload(subscription, status: "canceled")
        headers = webhook_headers(payload)

        expect { post(webhooks_creem_path, params: payload.to_json, headers:) }
          .to change_record(subscription, :status).to("canceled")
      end

      it "returns 404 when user not found" do
        object = subscription_object(email: "nonexistent@example.com")
        payload = { eventType: "subscription.canceled", object: }
        headers = webhook_headers(payload)

        post(webhooks_creem_path, params: payload.to_json, headers:)

        expect(response).to have_http_status(:not_found)
      end
    end

    describe "subscription.past_due" do
      it "sets subscription status to past_due" do
        subscription = create(:subscription, status: "active")
        payload = updated_payload(subscription, status: "past_due")
        headers = webhook_headers(payload)

        expect { post(webhooks_creem_path, params: payload.to_json, headers:) }
          .to change_record(subscription, :status).to("past_due")
      end

      it "returns 404 when user not found" do
        object = subscription_object(email: "nonexistent@example.com")
        payload = { eventType: "subscription.past_due", object: }
        headers = webhook_headers(payload)

        post(webhooks_creem_path, params: payload.to_json, headers:)

        expect(response).to have_http_status(:not_found)
      end
    end

    it "raises an error for unknown event types" do
      payload = { eventType: "charge.succeeded", object: { id: "ch_123" } }
      headers = webhook_headers(payload)

      expect { post(webhooks_creem_path, params: payload.to_json, headers:) }
        .to raise_error(ArgumentError, /wrong event type/)
    end
  end
end
