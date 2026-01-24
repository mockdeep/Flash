# frozen_string_literal: true

module Creem
  module CancelSubscription
    def self.call(subscription:)
      response = Client.post(
        "/subscriptions/#{subscription.creem_subscription_id}/cancel",
        { mode: "immediate" },
      )

      if response[:success]
        subscription.update!(status: "canceled")
        Result.new(success: true)
      else
        Result.new(success: false)
      end
    end

    class Result
      attr_accessor :success

      def initialize(success:)
        self.success = success
      end

      def success?
        success
      end
    end
  end
end
