# frozen_string_literal: true

RSpec.describe CssHelper do
  let(:helper) { Object.new.extend(described_class) }

  describe "#button_class" do
    it "returns base class with no modifiers" do
      expect(helper.button_class).to eq("button")
    end

    it "returns base class with a single modifier" do
      expect(helper.button_class(:primary)).to eq("button button--primary")
    end

    it "returns base class with multiple modifiers" do
      expect(helper.button_class(:secondary, :compact))
        .to eq("button button--secondary button--compact")
    end

    it "raises on unknown modifiers" do
      expect { helper.button_class(:nope) }
        .to raise_error(ArgumentError, /Unknown button modifier.*:nope/)
    end

    it "raises listing all unknown modifiers" do
      expect { helper.button_class(:primary, :foo, :bar) }
        .to raise_error(ArgumentError, /Unknown button modifier.*:foo.*:bar/)
    end

    it "supports all defined modifiers" do
      CssHelper::BUTTON_MODIFIERS.each do |mod|
        expect(helper.button_class(mod)).to eq("button button--#{mod}")
      end
    end
  end
end
