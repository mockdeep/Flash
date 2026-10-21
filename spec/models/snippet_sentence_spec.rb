# frozen_string_literal: true

require "rails_helper"

RSpec.describe SnippetSentence do
  it { is_expected.to belong_to(:source) }
  it { is_expected.to belong_to(:snippet) }

  it { is_expected.to validate_presence_of(:source) }
  it { is_expected.to validate_presence_of(:body) }
  it { is_expected.to validate_presence_of(:position) }

  it "takes only the known roles" do
    expect(build(:snippet_sentence, role: "footnote")).not_to be_valid
  end

  it "needs a snippet unless it is front matter" do
    expect(build(:snippet_sentence, snippet: nil)).not_to be_valid
  end

  it "needs no snippet as front matter" do
    expect(build(:snippet_sentence, snippet: nil, role: "title")).to be_valid
  end

  def check_constraints!
    described_class.connection.execute("SET CONSTRAINTS ALL IMMEDIATE")
  end

  it "keeps positions unique within a snippet" do
    sentence = create(:snippet_sentence)
    create(:snippet_sentence, **sentence.slice(:snippet, :position))

    expect { check_constraints! }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "lets positions pass each other until the transaction ends" do
    sentence = create(:snippet_sentence, position: 0)
    create(:snippet_sentence, snippet: sentence.snippet, position: 1)

    expect { sentence.update!(position: 1) }.not_to raise_error
  end

  it "keeps front matter positions unique within a source" do
    attributes = create(:front_matter).slice(:source, :position)

    expect { create(:front_matter, role: "author", **attributes) }
      .to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "keeps a body sentence in a snippet" do
    sentence = build(:snippet_sentence, snippet: nil)

    expect { sentence.save!(validate: false) }
      .to raise_error(ActiveRecord::StatementInvalid, /front_matter/)
  end

  describe "#title?" do
    it "is true for the source's title" do
      expect(build(:snippet_sentence, role: "title")).to be_title
    end

    it "is false for the source's author" do
      expect(build(:snippet_sentence, role: "author")).not_to be_title
    end
  end

  describe "#author?" do
    it "is true for the source's author" do
      expect(build(:snippet_sentence, role: "author")).to be_author
    end

    it "is false for a heading" do
      expect(build(:snippet_sentence, role: "heading")).not_to be_author
    end
  end

  describe "#heading?" do
    it "is true for a snippet's heading" do
      expect(build(:snippet_sentence, role: "heading")).to be_heading
    end

    it "is false for a body sentence" do
      expect(build(:snippet_sentence)).not_to be_heading
    end
  end

  describe "#front_matter?" do
    it "is true for the source's author" do
      expect(build(:snippet_sentence, role: "author")).to be_front_matter
    end

    it "is false for a heading" do
      expect(build(:snippet_sentence, role: "heading")).not_to be_front_matter
    end
  end

  describe ".unsegmented" do
    it "finds sentences without tokens" do
      sentence = create(:snippet_sentence, tokens: [])
      create(:snippet_sentence, tokens: [{ "text" => "我" }])

      expect(described_class.unsegmented).to eq([sentence])
    end
  end

  describe ".segmented" do
    it "finds sentences with tokens" do
      create(:snippet_sentence, tokens: [])
      sentence = create(:snippet_sentence, tokens: [{ "text" => "我" }])

      expect(described_class.segmented).to eq([sentence])
    end
  end

  describe ".pointing_at" do
    it "finds sentences with a token on the sense" do
      sense = create(:sense)
      sentence = create(:snippet_sentence, tokens: [{ "sense_id" => sense.id }])
      create(:snippet_sentence, tokens: [{ "sense_id" => create(:sense).id }])

      expect(described_class.pointing_at(sense)).to eq([sentence])
    end
  end

  describe ".sense_ids" do
    it "is every sense a token points at, once" do
      tokens = [{ "sense_id" => 7 }, { "text" => "。" }, { "sense_id" => 7 }]
      create(:snippet_sentence, tokens:)

      expect(described_class.sense_ids).to eq([7])
    end
  end

  describe "#awaiting_senses?" do
    def awaiting_senses?(*tokens)
      build(:snippet_sentence, tokens:).awaiting_senses?
    end

    it "is false for a skipped word" do
      expect(awaiting_senses?({ "text" => "我", "skip" => "foreign" }))
        .to be(false)
    end

    it "is true while a word has neither a sense nor an outcome" do
      expect(awaiting_senses?({ "text" => "我" })).to be(true)
    end

    it "is false once every word has an outcome" do
      token = { "text" => "我", "outcome" => "unresolved", "note" => "?" }

      expect(awaiting_senses?(token)).to be(false)
    end

    it "is false once every word has a sense" do
      expect(awaiting_senses?({ "text" => "我", "sense_id" => 1 })).to be(false)
    end

    it "is false for tokens without a Han character" do
      expect(awaiting_senses?({ "text" => "。" })).to be(false)
    end
  end

  describe "#word_chars" do
    it "returns the sentence's word characters without punctuation" do
      sentence = build(:snippet_sentence, body: "“你好，”他说。")

      expect(sentence.word_chars).to eq("你好他说")
    end
  end

  describe "#partitioned_by?" do
    def partitioned_by?(words)
      build(:snippet_sentence, body: "我爱你。").partitioned_by?(words)
    end

    it "is true when the words rejoin to the sentence" do
      expect(partitioned_by?(["我", "爱", "你", "。"])).to be(true)
    end

    it "ignores punctuation the words leave out" do
      expect(partitioned_by?(["我", "爱你"])).to be(true)
    end

    it "is false when a character is dropped" do
      expect(partitioned_by?(["我", "你"])).to be(false)
    end

    it "is false when a character is substituted" do
      expect(partitioned_by?(["我", "愛", "你"])).to be(false)
    end
  end

  describe "#status" do
    def status(*tokens) = build(:snippet_sentence, tokens:).status

    it "is new before segmenting" do
      expect(status).to eq(:new)
    end

    it "is finished with a skipped word" do
      expect(status({ "text" => "我", "skip" => "foreign" })).to eq(:finished)
    end

    it "is finished when every word has a sense" do
      tokens = [{ "text" => "我", "sense_id" => 1 }, { "text" => "。" }]

      expect(status(*tokens)).to eq(:finished)
    end

    it "is in progress while a word has no sense" do
      expect(status({ "text" => "我" })).to eq(:in_progress)
    end

    it "is in progress while a token carries working keys" do
      token = { "text" => "我", "sense_id" => 1, "outcome" => "matched" }

      expect(status(token)).to eq(:in_progress)
    end
  end
end
