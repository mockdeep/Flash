# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  def show
    subscription = current_user.subscription
    render(Views::Subscriptions::Show.new(subscription:))
  end

  def create
    # Create checkout session with Creem and redirect to checkout URL
    result = Creem::CreateCheckout.call(user: current_user)

    if result.success?
      redirect_to(result.checkout_url, allow_other_host: true)
    else
      flash[:error] = "Unable to create checkout session"
      redirect_to(subscription_path)
    end
  end

  def destroy
    subscription = current_user.subscription

    if subscription.blank?
      flash[:error] = "No active subscription found"
      redirect_to(subscription_path)
      return
    end

    result = Creem::CancelSubscription.call(subscription:)

    if result.success?
      flash[:success] = "Subscription canceled successfully"
    else
      flash[:error] = "Unable to cancel subscription"
    end

    redirect_to(subscription_path)
  end
end
