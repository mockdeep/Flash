# frozen_string_literal: true

require "rails_helper"

RSpec.describe Llm do
  describe ".client" do
    it "is the client set for the environment" do
      client = Llm::Fake.new
      described_class.client = client

      expect(described_class.client).to be(client)
    end

    it "raises when the environment uses no LLM" do
      described_class.client = nil

      expect { described_class.client }
        .to raise_error(Llm::Error, "No LLM is used in test")
    end
  end
end
