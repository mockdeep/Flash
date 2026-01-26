# frozen_string_literal: true

RSpec.describe Creem::CreateCheckout do
  def checkouts_url
    "https://api.creem.io/v1/checkouts"
  end

  def checkout_url
    "https://creem.io/checkout/test123"
  end

  def stub_creem_checkout(status:, body: {})
    stub_request(:post, checkouts_url).to_return(status:, body: body.to_json)
  end

  describe ".call" do
    context "when Creem API returns success" do
      it "returns success result" do
        user = create(:user)
        stub_creem_checkout(status: 200, body: { checkout_url: })

        result = described_class.call(user:)

        expect(result.success?).to be(true)
      end

      it "includes checkout URL" do
        user = create(:user)
        stub_creem_checkout(status: 200, body: { checkout_url: })

        result = described_class.call(user:)

        expect(result.checkout_url).to eq(checkout_url)
      end

      it "sends user email to Creem" do
        user = create(:user, email: "test@example.com")
        stub_creem_checkout(status: 200, body: { checkout_url: })

        described_class.call(user:)

        expect(WebMock).to have_requested(:post, checkouts_url)
          .with(body: hash_including(customer: { email: user.email }))
      end

      it "sends product ID to Creem" do
        user = create(:user)
        stub_creem_checkout(status: 200, body: { checkout_url: })

        described_class.call(user:)

        expect(WebMock).to have_requested(:post, checkouts_url)
          .with(body: hash_including(product_id: ENV.fetch("CREEM_PRODUCT_ID")))
      end
    end

    context "when Creem API returns failure" do
      it "returns failure result" do
        user = create(:user)
        stub_creem_checkout(status: 400)

        result = described_class.call(user:)

        expect(result.success?).to be(false)
      end

      it "does not include checkout URL" do
        user = create(:user)
        stub_creem_checkout(status: 500)

        result = described_class.call(user:)

        expect(result.checkout_url).to be_nil
      end
    end
  end
end
