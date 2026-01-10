# frozen_string_literal: true

class PolarService
  include HTTParty

  base_uri ENV.fetch("POLAR_API_URL", "https://api.polar.sh")

  def initialize
    @access_token = ENV.fetch("POLAR_ACCESS_TOKEN", nil)
    p @access_token
    raise "POLAR_ACCESS_TOKEN not configured" unless @access_token
  end

  # Create a checkout session for a subscription
  def create_checkout_session(product_id:, customer_email:, success_url:)
    post("/v1/checkouts/", {
      products: [product_id],
      customer_email: customer_email,
      success_url: success_url
    })
  end

  # Get checkout session details
  def get_checkout_session(checkout_id)
    get("/v1/checkouts/#{checkout_id}")
  end

  # Get subscription details
  def get_subscription(subscription_id)
    get("/v1/subscriptions/#{subscription_id}")
  end

  # Cancel a subscription
  def cancel_subscription(subscription_id)
    post("/v1/subscriptions/#{subscription_id}/cancel", {})
  end

  # List all products/subscription tiers
  def list_products(organization_id: nil)
    params = {}
    params[:organization_id] = organization_id if organization_id
    get("/v1/products", params)
  end

  # Get customer portal URL
  def get_customer_portal_url(customer_id)
    response = post("/v1/customer-portal-sessions", {
      customer_id: customer_id
    })
    response["url"] if response
  end

  private

  def headers
    {
      "Authorization" => "Bearer #{@access_token}",
      "Accept" => "application/json"
    }
  end

  def get(path, params = {})
    response = self.class.get(path, {
      headers: headers,
      query: params
    })

    handle_response(response)
  end

  def post(path, body = {})
    response = self.class.post(path, {
      headers: headers.merge("Content-Type" => "application/json"),
      body: body.to_json
    })

    p response

    handle_response(response)
  end

  def handle_response(response)
    case response.code
    when 200..299
      response.parsed_response
    when 401
      Rails.logger.error("Polar API authentication failed")
      nil
    when 404
      Rails.logger.error("Polar API resource not found")
      nil
    else
      Rails.logger.error("Polar API error: #{response.code} - #{response.body}")
      nil
    end
  rescue StandardError => e
    Rails.logger.error("Polar API request failed: #{e.message}")
    nil
  end
end
