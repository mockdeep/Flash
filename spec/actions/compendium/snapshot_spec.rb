# frozen_string_literal: true

require "rails_helper"

RSpec.describe Compendium::Snapshot do
  describe "#checksum" do
    it "is the same for the same rows" do
      create(:sense)
      first = export.checksum

      expect(export.checksum).to eq(first)
    end

    it "changes when a row changes" do
      sense = create(:sense)
      before = export.checksum
      sense.update!(gloss: "changed")

      expect(export.checksum).not_to eq(before)
    end
  end

  describe "#empty?" do
    it "is true when no table has rows" do
      expect(export).to be_empty
    end

    it "is false when a table has rows" do
      create(:entry)

      expect(export).not_to be_empty
    end
  end
end
