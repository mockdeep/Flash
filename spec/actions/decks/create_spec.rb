# frozen_string_literal: true

RSpec.describe Decks::Create do
  describe ".call" do
    def csv_file(content)
      file = Tempfile.new(["deck", ".csv"])
      file.write(content)
      file.rewind
      file
    end

    def create_deck(user:, name:, csv_content:)
      csv = csv_file(csv_content)
      described_class.call(user:, name:, cards_csv: csv)
    end

    context "when deck creation succeeds" do
      it "returns success result" do
        user = create(:user)
        csv_content = "front,back,category\nWhat is 2+2?,4,Math\n"

        result = create_deck(user:, name: "Test Deck", csv_content:)

        expect(result.success?).to be(true)
      end

      it "creates deck with correct name" do
        user = create(:user)
        csv_content = "front,back,category\nWhat is 2+2?,4,Math\n"

        result = create_deck(user:, name: "Test Deck", csv_content:)

        expect(result.record.name).to eq("Test Deck")
      end

      it "creates cards from CSV" do
        user = create(:user)
        csv_content = "front,back,category\nQ1,A1,C1\nQ2,A2,C2\n"

        result = create_deck(user:, name: "Test Deck", csv_content:)

        expect(result.record.cards.count).to eq(2)
      end

      it "sets card front" do
        user = create(:user)
        csv_content = "front,back,category\nWhat is 2+2?,4,Math\n"

        result = create_deck(user:, name: "Test Deck", csv_content:)

        expect(result.record.cards.first.front).to eq("What is 2+2?")
      end

      it "sets card back" do
        user = create(:user)
        csv_content = "front,back,category\nWhat is 2+2?,4,Math\n"

        result = create_deck(user:, name: "Test Deck", csv_content:)

        expect(result.record.cards.first.back).to eq("4")
      end

      it "sets card category" do
        user = create(:user)
        csv_content = "front,back,category\nWhat is 2+2?,4,Math\n"

        result = create_deck(user:, name: "Test Deck", csv_content:)

        expect(result.record.cards.first.category).to eq("Math")
      end

      it "sets card status to pending" do
        user = create(:user)
        csv_content = "front,back,category\nWhat is 2+2?,4,Math\n"

        result = create_deck(user:, name: "Test Deck", csv_content:)

        expect(result.record.cards.first.status).to eq("pending")
      end

      it "merges duplicate fronts with multiple backs" do
        user = create(:user)
        csv_content = "front,back,category\nQ,A1,C\nQ,A2,C\n"

        result = create_deck(user:, name: "Test Deck", csv_content:)

        expect(result.record.cards.first.back).to eq("A1;A2")
      end

      it "keeps single card for duplicate fronts" do
        user = create(:user)
        csv_content = "front,back,category\nQ,A1,C\nQ,A2,C\n"

        result = create_deck(user:, name: "Test Deck", csv_content:)

        expect(result.record.cards.count).to eq(1)
      end

      it "splits semicolon-separated answers" do
        user = create(:user)
        csv_content = "front,back,category\nColors?,Red;Blue,Art\n"

        result = create_deck(user:, name: "Test Deck", csv_content:)

        expect(result.record.cards.first.back).to eq("Red;Blue")
      end

      it "removes duplicate answers" do
        user = create(:user)
        csv_content = "front,back,category\nQ,A,C\nQ,A,C\n"

        result = create_deck(user:, name: "Test Deck", csv_content:)

        expect(result.record.cards.first.back).to eq("A")
      end
    end

    context "when deck creation fails" do
      it "returns failure result when name is blank" do
        user = create(:user)
        csv_content = "front,back,category\nWhat is 2+2?,4,Math\n"

        result = create_deck(user:, name: "", csv_content:)

        expect(result.success?).to be(false)
      end

      it "includes error message when name is blank" do
        user = create(:user)
        csv_content = "front,back,category\nWhat is 2+2?,4,Math\n"

        result = create_deck(user:, name: "", csv_content:)

        expect(result.record.errors[:name]).to include("can't be blank")
      end

      it "does not create cards when deck save fails" do
        user = create(:user)
        csv = "front,back,category\nQ,A,C\n"

        expect { create_deck(user:, name: "", csv_content: csv) }
          .not_to change(Card, :count)
      end
    end
  end
end
