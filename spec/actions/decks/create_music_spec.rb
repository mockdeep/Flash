# frozen_string_literal: true

RSpec.describe Decks::CreateMusic do
  describe ".call" do
    def csv_file(content)
      file = Tempfile.new(["deck", ".csv"])
      file.write(content)
      file.rewind
      file
    end

    def call_music(
      name:,
      csv_body:,
      headers: "front,back,category",
      user: create(:user),
      **
    )
      csv = csv_file("#{headers}\n#{csv_body}")
      described_class.call(user:, name:, cards_csv: csv, **)
    end

    it "creates a MusicDeck" do
      result = call_music(name: "Test", csv_body: "A3 Note,A3,Notes\n")

      expect(result.record).to be_a(MusicDeck)
    end

    it "creates MusicCards" do
      result = call_music(name: "Test", csv_body: "A3 Note,A3,Notes\n")

      expect(result.record.cards.first).to be_a(MusicCard)
    end

    it "defaults distractor_pool to 'none'" do
      result = call_music(name: "Test", csv_body: "A3 Note,A3,Notes\n")

      expect(result.record.distractor_pool).to eq("none")
    end

    it "rejects a comma-separated multi-note back" do
      body = "\"C Chord\",\"C4,E4,G4\",Chords\n"
      result = call_music(name: "Test", csv_body: body)

      expect(result.success?).to be(false)
    end

    it "accepts ordered:true and persists it on the deck" do
      body = "A3 Note,A3,Notes\n"
      result = call_music(name: "Test", csv_body: body, ordered: true)

      expect(result.record.ordered?).to be(true)
    end

    it "defaults ordered to false when not specified" do
      result = call_music(name: "Test", csv_body: "A3 Note,A3,Notes\n")

      expect(result.record.ordered?).to be(false)
    end

    it "rejects a row whose back is not a valid note sequence" do
      result = call_music(name: "Test", csv_body: "Bad,Hello,Notes\n")

      expect(result.success?).to be(false)
    end

    it "rejects a CSV with no rows" do
      result = call_music(name: "Test", csv_body: "")

      expect(result.record.errors[:cards_csv])
        .to include("must include at least one row")
    end

    it "rejects a row with a missing front" do
      result = call_music(name: "Test", csv_body: ",A3,Notes\n")

      expect(result.record.errors[:cards_csv])
        .to include("row 1 is missing a 'front' or 'back' value")
    end

    it "rejects a row with a missing back" do
      result = call_music(name: "Test", csv_body: "A3 Note,,Notes\n")

      expect(result.record.errors[:cards_csv])
        .to include("row 1 is missing a 'front' or 'back' value")
    end

    it "rejects a row with whitespace-only values" do
      result = call_music(name: "Test", csv_body: "   ,   ,Notes\n")

      expect(result.success?).to be(false)
    end

    it "rejects a back with space-separated notes (commas required)" do
      body = "C Chord,C4 E4 G4,Chords\n"
      result = call_music(name: "Test", csv_body: body)

      expect(result.success?).to be(false)
    end

    it "includes an error pointing at the bad row" do
      body = "Good,A3,Notes\nBad,X9,Notes\n"
      result = call_music(name: "Test", csv_body: body)

      expect(result.record.errors[:cards_csv])
        .to include("row 2: 'X9' is not a valid note")
    end

    it "rejects when name is blank" do
      result = call_music(name: "", csv_body: "A3 Note,A3,Notes\n")

      expect(result.success?).to be(false)
    end

    it "rejects when CSV is missing front header" do
      csv = csv_file("back,category\nA3,Notes\n")
      user = create(:user)

      result = described_class.call(user:, name: "Test", cards_csv: csv)

      expect(result.success?).to be(false)
    end

    it "rejects duplicate front values" do
      body = "Same,A3,Notes\nSame,B3,Notes\n"
      result = call_music(name: "Test", csv_body: body)

      expect(result.record.errors[:cards_csv])
        .to include("duplicate 'front' values: Same")
    end

    it "ignores any extra columns (e.g. distractors)" do
      headers = "front,back,category,distractors"
      body = "A3 Note,A3,Notes,foo;bar\n"
      result = call_music(name: "Test", csv_body: body, headers:)

      expect(result.success?).to be(true)
    end
  end
end
