# frozen_string_literal: true

require "rails_helper"

RSpec.describe Compendium::Pull do
  describe ".unpushed?" do
    def unpushed?(checksum)
      described_class.unpushed?(connection, Pathname(Dir.mktmpdir), checksum)
    end

    it "is false for an empty compendium" do
      expect(unpushed?(nil)).to be(false)
    end

    it "is false when the compendium matches the last sync" do
      create(:entry)

      expect(unpushed?(export.checksum)).to be(false)
    end

    it "is true when the compendium changed since the last sync" do
      create(:entry)

      expect(unpushed?("stale")).to be(true)
    end
  end
end
