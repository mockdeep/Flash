# frozen_string_literal: true

RSpec.describe Components::Base do
  describe ".new" do
    it "can be instantiated" do
      component = described_class.new

      expect(component).to be_a(described_class)
    end
  end

  describe "included helpers" do
    it "includes form helpers" do
      expect(described_class.include?(Phlex::Rails::Helpers::FormWith)).to be(true)
    end

    it "includes link helpers" do
      expect(described_class.include?(Phlex::Rails::Helpers::LinkTo)).to be(true)
    end

    it "includes button helpers" do
      expect(described_class.include?(Phlex::Rails::Helpers::ButtonTo)).to be(true)
    end

    it "includes image helpers" do
      expect(described_class.include?(Phlex::Rails::Helpers::ImageTag)).to be(true)
    end

    it "includes pluralize helpers" do
      expect(described_class.include?(Phlex::Rails::Helpers::Pluralize)).to be(true)
    end
  end

  describe "value helpers" do
    it "registers current_user as a value helper" do
      expect(described_class.value_helpers).to include(:current_user)
    end
  end
end