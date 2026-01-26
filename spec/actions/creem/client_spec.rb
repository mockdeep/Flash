# frozen_string_literal: true

RSpec.describe Creem::Client do
  def post_url
    "https://api.creem.io/v1/subscriptions/cancel"
  end

  def stub_creem_post(status:, body: {})
    stub_request(:post, post_url).to_return(status:, body: body.to_json)
  end

  describe ".post" do
    it "makes POST request to correct URL" do
      stub_creem_post(status: 200)

      described_class.post("/subscriptions/cancel")

      expect(WebMock).to have_requested(:post, post_url)
    end

    it "includes API key in headers" do
      stub_creem_post(status: 200)

      described_class.post("/subscriptions/cancel")

      expect(WebMock).to have_requested(:post, post_url)
        .with(headers: { "x-api-key" => "test_api_key_12345" })
    end

    it "includes Content-Type in headers" do
      stub_creem_post(status: 200)

      described_class.post("/subscriptions/cancel")

      expect(WebMock).to have_requested(:post, post_url).with(
        headers: { "Content-Type" => "application/json" },
      )
    end

    it "sends body as JSON" do
      stub_creem_post(status: 200)

      described_class.post("/subscriptions/cancel", mode: "immediate")

      expect(WebMock).to have_requested(:post, post_url)
        .with(body: { mode: "immediate" }.to_json)
    end

    context "when response is success (2xx)" do
      it "returns success true for 200 status" do
        stub_creem_post(status: 200, body: { id: "sub_123" })

        result = described_class.post("/subscriptions/cancel")

        expect(result[:success]).to be(true)
      end

      it "returns success true for 201 status" do
        stub_creem_post(status: 201, body: { id: "sub_123" })

        result = described_class.post("/subscriptions/cancel")

        expect(result[:success]).to be(true)
      end

      it "includes response data" do
        stub_creem_post(status: 200, body: { id: "sub_123" })

        result = described_class.post("/subscriptions/cancel")

        expect(result[:data]).to eq({ id: "sub_123" })
      end
    end

    context "when response is failure (non-2xx)" do
      it "returns success false for 400 status" do
        stub_creem_post(status: 400, body: { error: "Bad request" })

        result = described_class.post("/subscriptions/cancel")

        expect(result[:success]).to be(false)
      end

      it "returns success false for 500 status" do
        stub_creem_post(status: 500, body: { error: "Server error" })

        result = described_class.post("/subscriptions/cancel")

        expect(result[:success]).to be(false)
      end

      it "includes error data" do
        stub_creem_post(status: 400, body: { error: "Bad request" })

        result = described_class.post("/subscriptions/cancel")

        expect(result[:error]).to eq({ error: "Bad request" })
      end
    end
  end

  describe ".headers" do
    it "includes Content-Type application/json" do
      expect(described_class.headers["Content-Type"]).to eq("application/json")
    end

    it "includes API key from environment" do
      expect(described_class.headers["x-api-key"]).to eq("test_api_key_12345")
    end
  end

  describe ".parse_response" do
    it "returns success true for status 200" do
      body = '{"id":"sub_123"}'
      response = instance_double(Net::HTTPSuccess, code: "200", body:)

      result = described_class.parse_response(response)

      expect(result[:success]).to be(true)
    end

    it "returns success false for status 400" do
      body = '{"error":"Invalid"}'
      response = instance_double(Net::HTTPBadRequest, code: "400", body:)

      result = described_class.parse_response(response)

      expect(result[:success]).to be(false)
    end

    it "includes data for successful response" do
      body = '{"id":"sub_123"}'
      response = instance_double(Net::HTTPSuccess, code: "200", body:)

      result = described_class.parse_response(response)

      expect(result[:data]).to eq({ id: "sub_123" })
    end

    it "includes error for failed response" do
      body = '{"error":"Invalid"}'
      response = instance_double(Net::HTTPBadRequest, code: "400", body:)

      result = described_class.parse_response(response)

      expect(result[:error]).to eq({ error: "Invalid" })
    end

    it "symbolizes keys in response body" do
      body = '{"user_id":"123"}'
      response = instance_double(Net::HTTPSuccess, code: "200", body:)

      result = described_class.parse_response(response)

      expect(result[:data].keys).to include(:user_id)
    end
  end
end
