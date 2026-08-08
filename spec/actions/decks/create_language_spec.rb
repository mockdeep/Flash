# frozen_string_literal: true

RSpec.describe Decks::CreateLanguage do
  describe ".call" do
    def csv_file(content)
      file = Tempfile.new(["deck", ".csv"])
      file.write(content)
      file.rewind
      file
    end

    def call_with(csv, language: "zh", name: "T")
      described_class.call(
        user: create(:user), name:, cards_csv: csv_file(csv), language:,
      )
    end

    it "returns success result" do
      result = call_with("front,back\n明白,understand\n")

      expect(result.success?).to be(true)
    end

    it "builds a ReadingDeck" do
      deck = call_with("front,back\n明白,understand\n").record

      expect(deck).to be_a(ReadingDeck)
    end

    it "builds a LanguageDataSet" do
      deck = call_with("front,back\n明白,understand\n").record

      expect(deck.data_set).to be_a(LanguageDataSet)
    end

    it "stores the selected language on the data_set" do
      deck = call_with("front,back\n明白,understand\n", language: "es").record

      expect(deck.data_set.language).to eq("es")
    end

    it "creates cards from the CSV" do
      deck = call_with("front,back\n明白,understand\n爱,to love\n").record

      expect(deck.cards.count).to eq(2)
    end

    it "splits a multi-gloss back into rejoined glosses" do
      deck = call_with("front,back\n明白,understand;clear\n").record

      expect(deck.cards.first.back).to eq("understand; clear")
    end

    it "stores the reading on the card" do
      deck = call_with("front,back,reading\n两,two,liǎng\n").record

      expect(deck.cards.first.reading).to eq("liǎng")
    end

    it "sets distractor_pool to 'preset' with a distractors column" do
      deck = call_with("front,back,distractors\n两,two,three;four\n").record

      expect(deck.distractor_pool).to eq("preset")
    end

    it "returns failure when the language is blank" do
      result = call_with("front,back\n明白,understand\n", language: "")

      expect(result.success?).to be(false)
    end

    it "includes the language error on the record" do
      result = call_with("front,back\n明白,understand\n", language: "")

      expect(result.record.errors[:language]).to be_present
    end

    it "returns failure when the CSV is invalid" do
      result = call_with("foo,bar\n1,2\n")

      expect(result.record.errors[:cards_csv])
        .to include("must include 'front' and 'back' columns")
    end

    it "does not create a deck when the CSV is invalid" do
      expect { call_with("foo,bar\n1,2\n") }.not_to change(Deck, :count)
    end
  end
end
