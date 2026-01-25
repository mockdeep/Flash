# frozen_string_literal: true

require "rails_helper"

RSpec.describe Subscription do
  it { is_expected.to belong_to(:user) }

  it { is_expected.to validate_presence_of(:creem_subscription_id) }
  it { is_expected.to validate_presence_of(:status) }

  it "validates uniqueness of creem_subscription_id" do
    create(:subscription)

    expect(described_class.new)
      .to validate_uniqueness_of(:creem_subscription_id)
  end

  describe "#active?" do
    it "returns true when status is active" do
      subscription = build(:subscription)

      expect(subscription.active?).to be(true)
    end

    it "returns false when status is not active" do
      subscription = build(:subscription, :canceled)

      expect(subscription.active?).to be(false)
    end
  end

  describe "#canceled?" do
    it "returns true when status is canceled" do
      subscription = build(:subscription, :canceled)

      expect(subscription.canceled?).to be(true)
    end

    it "returns false when status is not canceled" do
      subscription = build(:subscription)

      expect(subscription.canceled?).to be(false)
    end
  end
end
