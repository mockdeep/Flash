# frozen_string_literal: true

RSpec.describe NullUser do
  describe "#authenticate" do
    it "returns false" do
      expect(described_class.new.authenticate("password")).to be(false)
    end
  end

  describe "#logged_in?" do
    it "returns false" do
      expect(described_class.new.logged_in?).to be(false)
    end
  end

  describe "#admin?" do
    it "returns false" do
      expect(described_class.new.admin?).to be(false)
    end
  end
end
