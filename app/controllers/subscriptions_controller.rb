# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: [:cancel]

  def show
    @subscription = current_user.subscription

    render(Views::Subscriptions::Show.new(subscription: @subscription))
  end

  def new
    product_id = ENV.fetch("POLAR_PRODUCT_ID", nil)

    unless product_id
      flash[:error] = "Subscription product not configured. Please contact support."
      redirect_to new_subscription_path
      return
    end

    polar_service = PolarService.new
    checkout_session = polar_service.create_checkout_session(
      product_id: product_id,
      customer_email: current_user.email,
      success_url: "#{create_subscription_url}?checkout_id={CHECKOUT_ID}"
    )

    p checkout_session

    if checkout_session && checkout_session["url"]
      redirect_to checkout_session["url"], allow_other_host: true
    else
      flash[:error] = "Failed to create checkout session. Please try again."
      redirect_to new_subscription_path
    end
  rescue StandardError => e
    Rails.logger.error("Subscription creation error: #{e.message}")
    flash[:error] = "An error occurred. Please try again later."
    redirect_to new_subscription_path
  end

  def create
    # This action is called after successful Polar checkout redirect
    # The actual subscription record is created by the webhook handler
    # We just verify the checkout was successful and show a success message

    checkout_id = params[:checkout_id] || params[:customer_session_token]

    unless checkout_id
      flash[:error] = "Invalid checkout session."
      redirect_to subscription_path
      return
    end

    polar_service = PolarService.new
    checkout_session = polar_service.get_checkout_session(checkout_id)

    unless checkout_session
      flash[:error] = "Failed to retrieve checkout session."
      redirect_to subscription_path
      return
    end

    # Check if checkout was successful
    unless checkout_session["status"] == "succeeded"
      flash[:error] = "Checkout was not completed successfully."
      redirect_to subscription_path
      return
    end

    # Success! The webhook will handle creating the subscription record
    flash[:notice] = "Thank you for subscribing! Your subscription will be activated shortly."
    redirect_to subscription_path
  rescue StandardError => e
    Rails.logger.error("Checkout verification error: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    flash[:error] = "An error occurred. Please try again later."
    redirect_to subscription_path
  end

  def cancel
    unless @subscription
      flash[:error] = "No active subscription found"
      redirect_to subscription_path
      return
    end

    polar_service = PolarService.new
    result = polar_service.cancel_subscription(@subscription.polar_subscription_id)

    if result
      @subscription.cancel!
      flash[:notice] = "Your subscription has been canceled"
    else
      flash[:error] = "Failed to cancel subscription. Please try again."
    end

    redirect_to subscription_path
  rescue StandardError => e
    Rails.logger.error("Subscription cancellation error: #{e.message}")
    flash[:error] = "An error occurred. Please try again later."
    redirect_to subscription_path
  end

  private

  def set_subscription
    @subscription = current_user.subscription
  end
end
