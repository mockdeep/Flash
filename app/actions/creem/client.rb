# frozen_string_literal: true

require "net/http"
require "json"

module Creem
  module Client
    extend self

    BASE_URL = "https://api.creem.io/v1"
    TEST_BASE_URL = "https://test-api.creem.io/v1"

    def post(path, body = {})
      uri = URI("#{base_url}#{path}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.path, headers)
      request.body = body.to_json

      response = http.request(request)
      parse_response(response)
    end

    def base_url
      Rails.env.production? ? BASE_URL : TEST_BASE_URL
    end

    def headers
      {
        "Content-Type" => "application/json",
        "x-api-key" => ENV.fetch("CREEM_API_KEY"),
      }
    end

    def parse_response(response)
      body = JSON.parse(response.body, symbolize_names: true)

      if response.code.to_i >= 200 && response.code.to_i < 300
        { success: true, data: body }
      else
        Rails.logger.error("Creem API error: #{body}")
        { success: false, error: body }
      end
    end
  end
end
