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
      flash[:error] = t(".error")
      redirect_to(subscription_path)
    end
  end

  def destroy
    subscription = current_user.subscription
    if subscription.blank?
      flash[:error] = t(".missing")
    else
      flash_cancellation(Creem::CancelSubscription.call(subscription:))
    end
    redirect_to(subscription_path)
  end

  private

  def flash_cancellation(result)
    if result.success?
      flash[:success] = t(".success")
    else
      flash[:error] = t(".error")
    end
  end
end
