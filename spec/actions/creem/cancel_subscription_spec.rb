# frozen_string_literal: true

RSpec.describe Creem::CancelSubscription do
  def cancel_url(subscription)
    sub_id = subscription.creem_subscription_id
    "https://test-api.creem.io/v1/subscriptions/#{sub_id}/cancel"
  end

  def stub_creem_cancel(subscription, status:, body: {})
    stub_request(:post, cancel_url(subscription))
      .to_return(status:, body: body.to_json)
  end

  describe ".call" do
    context "when Creem API returns success" do
      it "updates status to canceled" do
        subscription = create(:subscription)
        stub_creem_cancel(subscription, status: 200)

        expect { described_class.call(subscription:) }
          .to change_record(subscription, :status).from("active").to("canceled")
      end

      it "returns success result" do
        subscription = create(:subscription)
        stub_creem_cancel(subscription, status: 200)

        result = described_class.call(subscription:)

        expect(result.success?).to be(true)
      end

      it "sends immediate cancellation mode" do
        subscription = create(:subscription)
        stub_creem_cancel(subscription, status: 200)

        described_class.call(subscription:)

        expect(WebMock).to have_requested(:post, cancel_url(subscription))
          .with(body: hash_including(mode: "immediate"))
      end
    end

    context "when Creem API returns failure" do
      it "returns failure result" do
        subscription = create(:subscription)
        stub_creem_cancel(subscription, status: 400)

        result = described_class.call(subscription:)

        expect(result.success?).to be(false)
      end

      it "does not update subscription status" do
        subscription = create(:subscription)
        stub_creem_cancel(subscription, status: 500)

        expect { described_class.call(subscription:) }
          .not_to change_record(subscription, :status)
      end
    end
  end
end
