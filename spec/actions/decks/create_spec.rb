# frozen_string_literal: true

RSpec.describe Decks::Create do
  describe ".call" do
    def csv_file(content)
      file = Tempfile.new(["deck", ".csv"])
      file.write(content)
      file.rewind
      file
    end

    def first_content(result)
      result.record.cards.first
    end

    context "when deck creation succeeds" do
      it "returns success result" do
        user = create(:user)
        csv = csv_file("front,back,category\nWhat is 2+2?,4,Math\n")

        result = described_class.call(user:, name: "Test Deck", cards_csv: csv)

        expect(result.success?).to be(true)
      end

      it "handles a non-ASCII upload read as binary" do
        user = create(:user)
        # Uploaded files read back as ASCII-8BIT; a multi-byte front must still
        # round-trip into a pairing (regression: nil item_id NotNullViolation).
        csv = StringIO.new("front,back\n爱,to love\n".b)

        result = described_class.call(user:, name: "中文", cards_csv: csv)

        expect(result.record.cards.first.item.text).to eq("爱")
      end

      it "creates deck with correct name" do
        user = create(:user)
        csv = csv_file("front,back,category\nWhat is 2+2?,4,Math\n")

        result = described_class.call(user:, name: "Test Deck", cards_csv: csv)

        expect(result.record.name).to eq("Test Deck")
      end

      it "creates cards from CSV" do
        user = create(:user)
        csv = csv_file("front,back,category\nQ1,A1,C1\nQ2,A2,C2\n")

        result = described_class.call(user:, name: "Test Deck", cards_csv: csv)

        expect(result.record.cards.count).to eq(2)
      end

      it "sets card front" do
        user = create(:user)
        csv = csv_file("front,back,category\nWhat is 2+2?,4,Math\n")

        result = described_class.call(user:, name: "Test Deck", cards_csv: csv)

        expect(first_content(result).front).to eq("What is 2+2?")
      end

      it "sets card back" do
        user = create(:user)
        csv = csv_file("front,back,category\nWhat is 2+2?,4,Math\n")

        result = described_class.call(user:, name: "Test Deck", cards_csv: csv)

        expect(first_content(result).back).to eq("4")
      end

      it "sets card category" do
        user = create(:user)
        csv = csv_file("front,back,category\nWhat is 2+2?,4,Math\n")

        result = described_class.call(user:, name: "Test Deck", cards_csv: csv)

        expect(first_content(result).category).to eq("Math")
      end

      it "splits a multi-gloss back into rejoined glosses" do
        user = create(:user)
        csv = csv_file("front,back,category\nColors?,Red;Blue,Art\n")

        result = described_class.call(user:, name: "Test Deck", cards_csv: csv)

        expect(first_content(result).back).to eq("Red; Blue")
      end

      it "defaults distractor_pool to 'category'" do
        user = create(:user)
        csv = csv_file("front,back,category\nQ,A,C\n")

        result = described_class.call(user:, name: "Test Deck", cards_csv: csv)

        expect(result.record.distractor_pool).to eq("category")
      end
    end

    context "when mirroring to a data_set" do
      it "builds the data_set content from the cards" do
        user = create(:user)
        csv = csv_file("front,back\n明白,understand;clear\n")
        deck = described_class.call(user:, name: "T", cards_csv: csv).record

        expect(deck.cards.first.back).to eq("understand; clear")
      end

      it "detects Mandarin from the CSV content" do
        user = create(:user)
        csv = csv_file("front,back\n明白,understand\n")
        deck = described_class.call(user:, name: "T", cards_csv: csv).record

        expect(deck.data_set.language).to eq("zh")
      end

      it "leaves the language empty on a plain-text CSV" do
        user = create(:user)
        csv = csv_file("front,back\nQ,A\n")
        deck = described_class.call(user:, name: "T", cards_csv: csv).record

        expect(deck.data_set.language).to be_nil
      end
    end

    context "when CSV has a distractors column" do
      it "stores distractors on the card" do
        user = create(:user)
        csv = csv_file("front,back,category,distractors\nQ,A,C,W1;W2;W3\n")
        result = described_class.call(user:, name: "Test Deck", cards_csv: csv)

        expect(first_content(result).distractors).to eq(["W1", "W2", "W3"])
      end

      it "sets distractor_pool to 'preset'" do
        user = create(:user)
        csv = csv_file("front,back,category,distractors\nQ,A,C,W1;W2\n")
        result = described_class.call(user:, name: "Test Deck", cards_csv: csv)

        expect(result.record.distractor_pool).to eq("preset")
      end

      it "trims whitespace from distractors" do
        user = create(:user)
        csv = csv_file("front,back,category,distractors\nQ,A,C,  W1 ; W2  \n")
        result = described_class.call(user:, name: "Test Deck", cards_csv: csv)

        expect(first_content(result).distractors).to eq(["W1", "W2"])
      end

      it "rejects when a row has an empty distractors value" do
        user = create(:user)
        body = "Q1,A1,C1,W1;W2\nQ2,A2,C2,\n"
        csv = csv_file("front,back,category,distractors\n#{body}")
        result = described_class.call(user:, name: "Test Deck", cards_csv: csv)

        expect(result.success?).to be(false)
      end

      it "includes error about the row missing distractors" do
        user = create(:user)
        csv = csv_file("front,back,category,distractors\nQ,A,C,W\nQ2,A,C,\n")
        result = described_class.call(user:, name: "Test Deck", cards_csv: csv)
        expect(result.record.errors[:cards_csv])
          .to include("row 2 is missing a 'distractors' value")
      end
    end

    context "when deck creation fails" do
      it "returns failure result when name is blank" do
        user = create(:user)
        csv = csv_file("front,back,category\nWhat is 2+2?,4,Math\n")

        result = described_class.call(user:, name: "", cards_csv: csv)

        expect(result.success?).to be(false)
      end

      it "includes error message when name is blank" do
        user = create(:user)
        csv = csv_file("front,back,category\nWhat is 2+2?,4,Math\n")

        result = described_class.call(user:, name: "", cards_csv: csv)

        expect(result.record.errors[:name]).to include("can't be blank")
      end

      it "does not create cards when deck save fails" do
        user = create(:user)
        csv = csv_file("front,back,category\nQ,A,C\n")

        expect { described_class.call(user:, name: "", cards_csv: csv) }
          .not_to change(Card, :count)
      end

      it "returns failure when CSV is missing 'front' header" do
        user = create(:user)
        csv = csv_file("back,category\nA,C\n")

        result = described_class.call(user:, name: "Test Deck", cards_csv: csv)

        expect(result.success?).to be(false)
      end

      it "returns failure when CSV is missing 'back' header" do
        user = create(:user)
        csv = csv_file("front,category\nQ,C\n")

        result = described_class.call(user:, name: "Test Deck", cards_csv: csv)

        expect(result.success?).to be(false)
      end

      it "includes error about missing columns" do
        user = create(:user)
        csv = csv_file("foo,bar\n1,2\n")

        result = described_class.call(user:, name: "Test Deck", cards_csv: csv)

        expect(result.record.errors[:cards_csv])
          .to include("must include 'front' and 'back' columns")
      end

      it "returns failure when the CSV has no rows" do
        user = create(:user)
        csv = csv_file("front,back,category\n")

        result = described_class.call(user:, name: "Test Deck", cards_csv: csv)

        expect(result.record.errors[:cards_csv])
          .to include("must include at least one row")
      end

      it "returns failure when a row has blank front" do
        user = create(:user)
        csv = csv_file("front,back,category\n,A,C\n")

        result = described_class.call(user:, name: "Test Deck", cards_csv: csv)

        expect(result.success?).to be(false)
      end

      it "returns failure when a row has blank back" do
        user = create(:user)
        csv = csv_file("front,back,category\nQ,,C\n")

        result = described_class.call(user:, name: "Test Deck", cards_csv: csv)

        expect(result.success?).to be(false)
      end

      it "includes error about the row with missing value" do
        user = create(:user)
        csv = csv_file("front,back,category\nQ1,A1,C1\n,A2,C2\n")

        result = described_class.call(user:, name: "Test Deck", cards_csv: csv)

        expect(result.record.errors[:cards_csv])
          .to include("row 2 is missing a 'front' or 'back' value")
      end

      it "does not create cards when a row has blank values" do
        user = create(:user)
        cards_csv = csv_file("front,back,category\nQ,,C\n")

        expect { described_class.call(user:, name: "Test Deck", cards_csv:) }
          .not_to change(Card, :count)
      end

      it "does not create deck when CSV has missing headers" do
        user = create(:user)
        cards_csv = csv_file("foo,bar\n1,2\n")

        expect { described_class.call(user:, name: "Test", cards_csv:) }
          .not_to change(Deck, :count)
      end

      it "does not create deck when a row has blank values" do
        user = create(:user)
        cards_csv = csv_file("front,back,category\nQ,,C\n")

        expect { described_class.call(user:, name: "Test", cards_csv:) }
          .not_to change(Deck, :count)
      end

      it "rejects when there are duplicate front values" do
        user = create(:user)
        csv = csv_file("front,back,category\nQ,A1,C\nQ,A2,C\n")

        result = described_class.call(user:, name: "Test Deck", cards_csv: csv)

        expect(result.success?).to be(false)
      end

      it "includes error listing the duplicate fronts" do
        user = create(:user)
        csv = csv_file("front,back,category\nQ,A1,C\nQ,A2,C\n")

        result = described_class.call(user:, name: "Test Deck", cards_csv: csv)

        expect(result.record.errors[:cards_csv])
          .to include("duplicate 'front' values: Q")
      end
    end

    context "when CSV has example columns" do
      def example_body
        "front,back,category,example_front,example_back\n" \
          "Q,A,C,Hola mundo,Hello world\n"
      end

      def call_with_body(body)
        described_class.call(
          user: create(:user),
          name: "T",
          cards_csv: csv_file(body),
        )
      end

      it "stores example_front on the card" do
        card = call_with_body(example_body).record.cards.first

        expect(card.example_front).to eq("Hola mundo")
      end

      it "stores example_back on the card" do
        card = call_with_body(example_body).record.cards.first

        expect(card.example_back).to eq("Hello world")
      end

      it "leaves both example fields nil when both row values are blank" do
        body = "front,back,category,example_front,example_back\nQ,A,C,,\n"
        card = call_with_body(body).record.cards.first

        expect(card).to have_attributes(example_front: nil, example_back: nil)
      end

      it "rejects when a row has only example_front" do
        body = "front,back,category,example_front,example_back\nQ,A,C,Hola,\n"
        errors = call_with_body(body).record.errors[:cards_csv]

        expect(errors).to include(a_string_matching(/row 1 must include both/))
      end

      it "rejects when only one of the example columns is present" do
        body = "front,back,category,example_front\nQ,A,C,Hola\n"
        errors = call_with_body(body).record.errors[:cards_csv]

        expect(errors).to include(a_string_matching(/must include both/))
      end
    end

    context "when CSV has a reading column" do
      def call_with(body)
        described_class.call(
          user: create(:user),
          name: "T",
          cards_csv: csv_file(body),
        )
      end

      it "stores the reading on the card" do
        card = call_with("front,back,category,reading\n两,two,Num,liǎng\n")
          .record.cards.first

        expect(card.reading).to eq("liǎng")
      end

      it "leaves a row's reading nil when blank" do
        card = call_with("front,back,category,reading\n三,three,Num,\n")
          .record.cards.first

        expect(card.reading).to be_nil
      end
    end

    context "when CSV has no reading column" do
      it "leaves reading nil" do
        user = create(:user)
        csv = csv_file("front,back,category\nQ,A,C\n")

        result = described_class.call(user:, name: "Test Deck", cards_csv: csv)

        expect(first_content(result).reading).to be_nil
      end
    end

    context "when category column is missing" do
      it "succeeds with empty category" do
        user = create(:user)
        csv = csv_file("front,back\nQ,A\n")

        result = described_class.call(user:, name: "Test Deck", cards_csv: csv)

        expect(result.success?).to be(true)
      end

      it "sets category to empty string" do
        user = create(:user)
        csv = csv_file("front,back\nQ,A\n")

        result = described_class.call(user:, name: "Test Deck", cards_csv: csv)

        expect(first_content(result).category).to eq("")
      end
    end
  end
end
