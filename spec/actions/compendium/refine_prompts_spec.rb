# frozen_string_literal: true

require "rails_helper"

RSpec.describe Compendium::RefinePrompts do
  describe ".flag" do
    it "is the general prompt for a language with no lexicon of its own" do
      expect(described_class.flag("ja")).to eq(described_class::FLAG)
    end

    it "adds a language's own rules" do
      expect(described_class.flag("zh"))
        .to include(Snippets::Mandarin::Policy::READING)
    end

    it "adds the categories a language's lists use" do
      expect(described_class.flag("pt")).to include("Categories: noun, verb")
    end

    it "says a language has no readings" do
      expect(described_class.flag("de")).to include("Readings: none")
    end

    it "names a language's articles" do
      expect(described_class.flag("de"))
        .to include("Articles: der, die, das, in `article`")
    end
  end

  describe ".confirm" do
    it "adds a language's own rules" do
      expect(described_class.confirm("pt"))
        .to include(Snippets::Portuguese::ARTICLES)
    end
  end
end
