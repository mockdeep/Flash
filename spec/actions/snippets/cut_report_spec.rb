# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::CutReport do
  def words(*texts)
    texts.map { { "text" => it } }
  end

  def sentence(source, *texts)
    snippet = create(:snippet, source:)
    create(:snippet_sentence, snippet:, tokens: words(*texts))
  end

  def report(sentences, source)
    described_class.call(sentences, source)
  end

  it "lists a word the stretch cuts and another sentence keeps whole" do
    source = create(:source)
    cut = sentence(source, "天", "上")
    sentence(source, "天上")

    expect(report([cut], source))
      .to eq(["  天上: cut 天 + 上 in sentence #{cut.id}; whole in 1 other"])
  end

  it "lists a word the stretch keeps whole and another sentence cuts" do
    source = create(:source)
    whole = sentence(source, "天上")
    sentence(source, "天", "上")

    expect(report([whole], source))
      .to eq(["  天上: whole in sentence #{whole.id}; cut 天 + 上 in 1 other"])
  end

  it "names every sentence of the stretch that cuts the word" do
    source = create(:source)
    cuts = Array.new(2) { sentence(source, "天", "上") }
    Array.new(3) { sentence(source, "天上") }

    expect(report(cuts, source).first)
      .to include("in sentences #{cuts.map(&:id).join(", ")};")
  end

  it "finds a cut of more than two words" do
    source = create(:source)
    cut = sentence(source, "八", "卦", "炉")
    sentence(source, "八卦炉")

    expect(report([cut], source).first).to include("cut 八 + 卦 + 炉")
  end

  it "leaves out a sentence that uses the commoner form" do
    source = create(:source)
    whole = sentence(source, "天上")
    sentence(source, "天上")
    sentence(source, "天", "上")

    expect(report([whole], source)).to be_empty
  end

  it "names both forms when the source uses each as often" do
    source = create(:source)
    stretch = [sentence(source, "天上"), sentence(source, "天", "上")]

    expect(report(stretch, source).size).to eq(2)
  end

  it "leaves out a word no sentence cuts" do
    source = create(:source)
    whole = sentence(source, "天上")

    expect(report([whole], source)).to be_empty
  end

  it "leaves out a word only sentences outside the stretch cut" do
    source = create(:source)
    sentence(source, "天", "上")
    sentence(source, "天上")
    other = sentence(source, "我")

    expect(report([other], source)).to be_empty
  end

  it "joins no words across punctuation" do
    source = create(:source)
    cut = sentence(source, "天", "，", "上")
    sentence(source, "天上")

    expect(report([cut], source)).to be_empty
  end

  it "leaves out a word only another source keeps whole" do
    source = create(:source)
    cut = sentence(source, "天", "上")
    sentence(create(:source), "天上")

    expect(report([cut], source)).to be_empty
  end

  it "joins words with a space in a language written with spaces" do
    source = create(:source, word_list: create(:word_list, language: "pt"))
    cut = sentence(source, "de", "repente")
    sentence(source, "de repente")

    expect(report([cut], source).first)
      .to include("de repente: cut de + repente")
  end
end
