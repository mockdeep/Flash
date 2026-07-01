# frozen_string_literal: true

module Creem
  module CreateCheckout
    extend self

    def call(user:)
      product_id = ENV.fetch("CREEM_PRODUCT_ID")
      success_url = Rails.application.routes.url_helpers.subscription_url
      customer = { email: user.email }

      response =
        Client.post("/checkouts", { product_id:, customer:, success_url: })

      if response[:success]
        checkout_url = response[:data][:checkout_url]
        Result.new(success: true, checkout_url:)
      else
        Result.new(success: false, checkout_url: nil)
      end
    end

    class Result
      attr_accessor :success, :checkout_url

      def initialize(success:, checkout_url:)
        self.success = success
        self.checkout_url = checkout_url
      end

      def success?
        success
      end
    end
  end
end
