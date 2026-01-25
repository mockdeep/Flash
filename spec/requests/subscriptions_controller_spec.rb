# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubscriptionsController do
  def checkouts_url
    "https://test-api.creem.io/v1/checkouts"
  end

  def checkout_url
    "https://creem.io/checkout/test123"
  end

  def stub_creem_checkout(status:, body: {})
    stub_request(:post, checkouts_url)
      .to_return(status: status, body: body.to_json)
  end

  def cancel_url(subscription)
    sub_id = subscription.creem_subscription_id
    "https://test-api.creem.io/v1/subscriptions/#{sub_id}/cancel"
  end

  def stub_creem_cancel(subscription, status:, body: {})
    stub_request(:post, cancel_url(subscription))
      .to_return(status: status, body: body.to_json)
  end

  describe "#show" do
    it "renders the subscription page" do
      login_as(default_user)

      get(subscription_path)

      expect(rendered).to have_content("Subscription")
    end
  end

  describe "#create" do
    context "when checkout creation succeeds" do
      it "redirects to Creem checkout URL" do
        user = default_user
        stub_creem_checkout(status: 200, body: { checkout_url: })

        login_as(user)
        post(subscription_path)

        expect(response).to redirect_to(checkout_url)
      end
    end

    context "when checkout creation fails" do
      it "redirects to subscription page" do
        user = default_user
        stub_creem_checkout(status: 400)

        login_as(user)
        post(subscription_path)

        expect(response).to redirect_to(subscription_path)
      end

      it "sets error flash message" do
        user = default_user
        stub_creem_checkout(status: 400)

        login_as(user)
        post(subscription_path)

        expect(flash[:error]).to eq("Unable to create checkout session")
      end
    end
  end

  describe "#destroy" do
    def cancel_subscription(user:, subscription: nil, api_status: nil)
      create(:subscription, user:) if subscription.nil? && api_status
      stub_creem_cancel(user.subscription, status: api_status) if api_status

      login_as(user)
      delete(subscription_path)
    end

    context "when user has no subscription" do
      it "redirects to subscription page" do
        cancel_subscription(user: default_user)

        expect(response).to redirect_to(subscription_path)
      end

      it "sets error flash message" do
        cancel_subscription(user: default_user)

        expect(flash[:error]).to eq("No active subscription found")
      end
    end

    context "when cancellation succeeds" do
      it "redirects to subscription page" do
        cancel_subscription(user: default_user, api_status: 200)

        expect(response).to redirect_to(subscription_path)
      end

      it "sets success flash message" do
        cancel_subscription(user: default_user, api_status: 200)

        expect(flash[:success]).to eq("Subscription canceled successfully")
      end
    end

    context "when cancellation fails" do
      it "redirects to subscription page" do
        cancel_subscription(user: default_user, api_status: 400)

        expect(response).to redirect_to(subscription_path)
      end

      it "sets error flash message" do
        cancel_subscription(user: default_user, api_status: 400)

        expect(flash[:error]).to eq("Unable to cancel subscription")
      end
    end
  end
end
