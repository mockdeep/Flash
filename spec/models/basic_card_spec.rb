# frozen_string_literal: true

require "rails_helper"

RSpec.describe BasicCard do
  describe ".model_name" do
    it "returns the Card model name for routing" do
      expect(described_class.model_name.route_key).to eq("cards")
    end
  end
end
