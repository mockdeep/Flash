# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubscriptionsController do
  def checkouts_url
    "https://api.creem.io/v1/checkouts"
  end

  def checkout_url
    "https://creem.io/checkout/test123"
  end

  def stub_creem_checkout(status:, body: {})
    stub_request(:post, checkouts_url).to_return(status:, body: body.to_json)
  end

  def cancel_url(subscription)
    sub_id = subscription.creem_subscription_id
    "https://api.creem.io/v1/subscriptions/#{sub_id}/cancel"
  end

  def stub_creem_cancel(subscription, status:, body: {})
    stub_request(:post, cancel_url(subscription))
      .to_return(status:, body: body.to_json)
  end

  describe "#show" do
    it "renders the subscription page" do
      login_as(default_user)

      get(subscription_path)

      expect(rendered).to have_content("Subscription")
    end

    it "shows no subscription message when user has no subscription" do
      login_as(default_user)

      get(subscription_path)

      expect(rendered).to have_content("don't have an active subscription")
    end

    it "shows active subscriber badge when user has subscription" do
      create(:subscription, status: "active")
      login_as(default_user)

      get(subscription_path)

      expect(rendered).to have_content("Active Subscriber")
    end

    it "shows subscription status" do
      create(:subscription, status: "active")
      login_as(default_user)

      get(subscription_path)

      expect(rendered).to have_content("Active")
    end

    it "shows plan name" do
      create(:subscription, plan_name: "Monthly Plan")
      login_as(default_user)

      get(subscription_path)

      expect(rendered).to have_content("Monthly Plan")
    end

    it "shows next billing date when period end is set" do
      create(:subscription, current_period_end: Date.new(2026, 2, 15))
      login_as(default_user)

      get(subscription_path)

      expect(rendered).to have_content("February 15, 2026")
    end

    it "shows cancel form for active subscription" do
      create(:subscription, status: "active")
      login_as(default_user)

      get(subscription_path)

      expect(rendered).to have_css("input[value='Cancel Subscription']")
    end

    it "does not show cancel button for canceled subscription" do
      create(:subscription, status: "canceled")
      login_as(default_user)

      get(subscription_path)

      expect(rendered).to have_no_css("input[value='Cancel Subscription']")
    end
  end

  describe "#create" do
    context "when checkout creation succeeds" do
      it "redirects to Creem checkout URL" do
        stub_creem_checkout(status: 200, body: { checkout_url: })
        login_as(default_user)

        post(subscription_path)

        expect(response).to redirect_to(checkout_url)
      end
    end

    context "when checkout creation fails" do
      it "redirects to subscription page" do
        stub_creem_checkout(status: 400)
        login_as(default_user)

        post(subscription_path)

        expect(response).to redirect_to(subscription_path)
      end

      it "sets error flash message" do
        stub_creem_checkout(status: 400)
        login_as(default_user)

        post(subscription_path)

        expect(flash[:error]).to eq("Unable to create checkout session")
      end
    end
  end

  describe "#destroy" do
    context "when user has no subscription" do
      it "redirects to subscription page" do
        login_as(default_user)

        delete(subscription_path)

        expect(response).to redirect_to(subscription_path)
      end

      it "sets error flash message" do
        login_as(default_user)

        delete(subscription_path)

        expect(flash[:error]).to eq("No active subscription found")
      end
    end

    context "when cancellation succeeds" do
      it "redirects to subscription page" do
        subscription = create(:subscription)
        stub_creem_cancel(subscription, status: 200)
        login_as(default_user)

        delete(subscription_path)

        expect(response).to redirect_to(subscription_path)
      end

      it "sets success flash message" do
        subscription = create(:subscription)
        stub_creem_cancel(subscription, status: 200)
        login_as(default_user)

        delete(subscription_path)

        expect(flash[:success]).to eq("Subscription canceled successfully")
      end
    end

    context "when cancellation fails" do
      it "redirects to subscription page" do
        subscription = create(:subscription)
        stub_creem_cancel(subscription, status: 400)
        login_as(default_user)

        delete(subscription_path)

        expect(response).to redirect_to(subscription_path)
      end

      it "sets error flash message" do
        subscription = create(:subscription)
        stub_creem_cancel(subscription, status: 400)
        login_as(default_user)

        delete(subscription_path)

        expect(flash[:error]).to eq("Unable to cancel subscription")
      end
    end
  end
end
