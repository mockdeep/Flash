# frozen_string_literal: true

RSpec.describe Decks::Replace do
  describe ".call" do
    def csv_file(content)
      file = Tempfile.new(["deck", ".csv"])
      file.write(content)
      file.rewind
      file
    end

    def replace_with(deck, csv_content)
      described_class.call(deck:, cards_csv: csv_file(csv_content))
    end

    def card_with_progress(deck, front:, back:, **overrides)
      create(
        :card,
        deck:,
        front:,
        back:,
        correct_streak: 2,
        correct_count: 5,
        view_count: 7,
        **overrides,
      )
    end

    def card_fronts(deck)
      Card.where(deck_id: deck.id).pluck(:front)
    end

    context "when a kept card is completely unchanged" do
      it "does not touch updated_at" do
        deck = create(:deck)
        card = card_with_progress(deck, front: "Q", back: "A", category: "C")
        original_updated_at = card.updated_at
        replace_with(deck, "front,back,category\nQ,A,C\n")

        expect(card.reload.updated_at).to eq(original_updated_at)
      end
    end

    context "when only category and distractors change on a card" do
      it "preserves correct_streak" do
        deck = create(:deck)
        card = card_with_progress(deck, front: "Q", back: "A", category: "Old")
        replace_with(deck, "front,back,category\nQ,A,New\n")

        expect(card.reload.correct_streak).to eq(2)
      end

      it "preserves correct_count" do
        deck = create(:deck)
        card = card_with_progress(deck, front: "Q", back: "A", category: "Old")
        replace_with(deck, "front,back,category\nQ,A,New\n")

        expect(card.reload.correct_count).to eq(5)
      end

      it "preserves view_count" do
        deck = create(:deck)
        card = card_with_progress(deck, front: "Q", back: "A", category: "Old")
        replace_with(deck, "front,back,category\nQ,A,New\n")

        expect(card.reload.view_count).to eq(7)
      end

      it "updates category" do
        deck = create(:deck)
        card = card_with_progress(deck, front: "Q", back: "A", category: "Old")
        replace_with(deck, "front,back,category\nQ,A,New\n")

        expect(card.reload.category).to eq("New")
      end
    end

    context "when a card's back changes" do
      it "resets correct_streak to 0" do
        deck = create(:deck)
        card = card_with_progress(deck, front: "Q", back: "Old")
        replace_with(deck, "front,back,category\nQ,New,Math\n")

        expect(card.reload.correct_streak).to eq(0)
      end

      it "resets correct_count to 0" do
        deck = create(:deck)
        card = card_with_progress(deck, front: "Q", back: "Old")
        replace_with(deck, "front,back,category\nQ,New,Math\n")

        expect(card.reload.correct_count).to eq(0)
      end

      it "resets view_count to 0" do
        deck = create(:deck)
        card = card_with_progress(deck, front: "Q", back: "Old")
        replace_with(deck, "front,back,category\nQ,New,Math\n")

        expect(card.reload.view_count).to eq(0)
      end

      it "updates back to the new value" do
        deck = create(:deck)
        card = card_with_progress(deck, front: "Q", back: "Old")
        replace_with(deck, "front,back,category\nQ,New,Math\n")

        expect(card.reload.back).to eq("New")
      end
    end

    context "when CSV contains a new front" do
      it "inserts the new card" do
        deck = create(:deck)
        card_with_progress(deck, front: "Q1", back: "A1")
        replace_with(deck, "front,back,category\nQ1,A1,C\nQ2,A2,C\n")

        expect(card_fronts(deck)).to contain_exactly("Q1", "Q2")
      end

      it "starts the new card with zero correct_streak" do
        deck = create(:deck)
        replace_with(deck, "front,back,category\nQ,A,C\n")

        expect(deck.cards.find_by(front: "Q").correct_streak).to eq(0)
      end
    end

    context "when a card's front is missing from the new CSV" do
      it "deletes the missing card" do
        deck = create(:deck)
        card_with_progress(deck, front: "Q1", back: "A1")
        card_with_progress(deck, front: "Q2", back: "A2")
        replace_with(deck, "front,back,category\nQ1,A1,C\n")

        expect(card_fronts(deck)).to contain_exactly("Q1")
      end
    end

    context "when CSV adds a distractors column" do
      it "re-derives distractor_pool to 'preset'" do
        deck = create(:deck, distractor_pool: "category")
        card_with_progress(deck, front: "Q", back: "A")
        replace_with(deck, "front,back,category,distractors\nQ,A,C,W1;W2\n")

        expect(deck.reload.distractor_pool).to eq("preset")
      end

      it "stores distractors on the card" do
        deck = create(:deck, distractor_pool: "category")
        card = card_with_progress(deck, front: "Q", back: "A")
        replace_with(deck, "front,back,category,distractors\nQ,A,C,W1;W2\n")

        expect(card.reload.distractors).to eq(["W1", "W2"])
      end

      it "preserves progress when only distractors are added" do
        deck = create(:deck, distractor_pool: "category")
        card = card_with_progress(deck, front: "Q", back: "A")
        body = "front,back,category,distractors\nQ,A,General,W1;W2\n"
        replace_with(deck, body)

        expect(card.reload.correct_streak).to eq(2)
      end
    end

    context "when CSV drops the distractors column" do
      it "re-derives distractor_pool to 'category'" do
        deck = create(:deck, distractor_pool: "preset")
        create(:card, deck:, front: "Q", back: "A", distractors: ["W1"])
        replace_with(deck, "front,back,category\nQ,A,C\n")

        expect(deck.reload.distractor_pool).to eq("category")
      end
    end

    context "when the result summary is inspected" do
      it "reports added count" do
        deck = create(:deck)
        card_with_progress(deck, front: "Same", back: "Same")
        body = "front,back,category\nSame,Same,C\nFresh,F,C\n"

        expect(replace_with(deck, body).summary.added).to eq(1)
      end

      it "reports removed count" do
        deck = create(:deck)
        card_with_progress(deck, front: "Same", back: "Same")
        card_with_progress(deck, front: "Removed", back: "Bye")
        body = "front,back,category\nSame,Same,C\n"

        expect(replace_with(deck, body).summary.removed).to eq(1)
      end

      it "reports reset count" do
        deck = create(:deck)
        card_with_progress(deck, front: "Q", back: "Old")
        body = "front,back,category\nQ,New,C\n"

        expect(replace_with(deck, body).summary.reset).to eq(1)
      end

      it "reports kept count" do
        deck = create(:deck)
        card_with_progress(deck, front: "Q", back: "A")
        body = "front,back,category\nQ,A,C\n"

        expect(replace_with(deck, body).summary.kept).to eq(1)
      end
    end

    context "when CSV is invalid" do
      it "returns failure for missing headers" do
        deck = create(:deck)
        result = replace_with(deck, "foo,bar\n1,2\n")

        expect(result.success?).to be(false)
      end

      it "leaves existing cards untouched" do
        deck = create(:deck)
        card = card_with_progress(deck, front: "Q", back: "A")
        replace_with(deck, "foo,bar\n1,2\n")

        expect(card.reload.back).to eq("A")
      end

      it "leaves distractor_pool untouched" do
        deck = create(:deck, distractor_pool: "category")
        card_with_progress(deck, front: "Q", back: "A")
        replace_with(deck, "foo,bar\n1,2\n")

        expect(deck.reload.distractor_pool).to eq("category")
      end

      it "adds the error message to the deck" do
        deck = create(:deck)
        result = replace_with(deck, "foo,bar\n1,2\n")

        expect(result.record.errors[:cards_csv])
          .to include("must include 'front' and 'back' columns")
      end
    end
  end
end
