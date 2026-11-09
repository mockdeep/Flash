# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::CurriculumReport do
  def listed(headword)
    list = create(:word_list, curriculum: true)
    entry = create(:entry, headword:)
    create(:sense_membership, sense: create(:sense, entry:), word_list: list)
  end

  def sentence(*texts)
    tokens = texts.map { { "text" => it } }
    create(:snippet_sentence, body: texts.join, tokens:)
  end

  it "lists a curriculum word cut into tokens" do
    listed("东西")
    cut = sentence("买", "东", "西")

    expect(described_class.call([cut]))
      .to eq(["  东西: cut 东 + 西 in sentence #{cut.id}"])
  end

  it "names every sentence that cuts the word" do
    listed("东西")
    cuts = Array.new(2) { sentence("东", "西") }

    expect(described_class.call(cuts).sole)
      .to include("in sentences #{cuts.map(&:id).join(", ")}")
  end

  it "leaves out a word a token holds whole" do
    listed("东西")

    expect(described_class.call([sentence("买", "东西")])).to be_empty
  end

  it "leaves out a word inside a longer token" do
    listed("东西")

    expect(described_class.call([sentence("东西南北")])).to be_empty
  end

  it "leaves out a word that straddles a token's edge" do
    listed("着眼")

    expect(described_class.call([sentence("看", "着", "眼睛")])).to be_empty
  end

  it "lists nothing for no sentences" do
    expect(described_class.call([])).to be_empty
  end
end
