# frozen_string_literal: true

require "rails_helper"

RSpec.describe Lexicon do
  describe ".for" do
    it "finds a language's own lexicon" do
      expect(described_class.for("de")).to eq(described_class::GERMAN)
    end

    it "gives any other language a plain one" do
      expect(described_class.for("it").articles).to be_empty
    end
  end
end
