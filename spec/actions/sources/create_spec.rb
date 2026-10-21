# frozen_string_literal: true

require "rails_helper"

RSpec.describe Sources::Create do
  def create_source(title: "孔乙己", language: "zh")
    described_class.call(user: default_user, title:, language:, author: "鲁迅")
  end

  describe ".call" do
    it "saves the source" do
      expect(create_source.record).to have_attributes(
        title: "孔乙己",
        author: "鲁迅",
      )
    end

    it "makes a Mandarin word_list named after it" do
      expect(create_source.record.word_list)
        .to have_attributes(name: "孔乙己", language: "zh", user: default_user)
    end

    it "makes the word_list in the language chosen" do
      expect(create_source(language: "pt").record.word_list.language)
        .to eq("pt")
    end

    it "refuses a source without a language" do
      expect(create_source(language: nil).record.errors[:base])
        .to eq(["List language is not supported"])
    end

    it "saves its title and author as front matter" do
      expect(create_source.record.front_matter.pluck(:role, :body, :position))
        .to eq([["title", "孔乙己", 0], ["author", "鲁迅", 1]])
    end

    it "saves no author line without an author" do
      source = described_class
        .call(user: default_user, title: "孔乙己", language: "zh").record

      expect(source.front_matter.pluck(:role)).to eq(["title"])
    end

    it "returns a success result" do
      expect(create_source).to be_success
    end

    context "when the source is invalid" do
      it "returns a failure result" do
        expect(create_source(title: "")).not_to be_success
      end

      it "does not create the word_list" do
        expect { create_source(title: "") }.not_to change(WordList, :count)
      end
    end

    context "when the user has a list of that name" do
      it "reports the title as taken" do
        create(:word_list, name: "孔乙己")

        expect(create_source.record.errors.full_messages)
          .to include("Title has already been taken")
      end
    end
  end
end
