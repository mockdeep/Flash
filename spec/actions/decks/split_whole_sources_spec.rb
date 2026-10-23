# frozen_string_literal: true

RSpec.describe Decks::SplitWholeSources do
  def split = described_class.call(dry_run: false)

  # A deck over a whole source whose first section is finished.
  def whole_deck(**)
    snippet = create(:snippet, :finished)
    create(:reading_deck, word_list: snippet.word_list, **)
  end

  describe ".call" do
    it "writes nothing on a dry run" do
      deck = whole_deck

      expect { described_class.call }.not_to(change { deck.reload.snippet })
    end

    it "moves a whole source's deck onto its first section" do
      deck = whole_deck

      split

      expect(deck.reload.snippet).to eq(deck.source.first_section)
    end

    it "reports the decks it moves" do
      deck = whole_deck

      expect(split.converted).to eq([deck.id])
    end

    def with_section_deck
      deck = whole_deck
      section = deck.source.first_section
      create(:reading_deck, word_list: deck.word_list, snippet: section)
      deck
    end

    it "deletes one whose owner has a deck for that section" do
      deck = with_section_deck

      expect { split }.to delete_record(deck)
    end

    it "reports the decks it deletes" do
      deck = with_section_deck

      expect(split.deleted).to eq([deck.id])
    end

    it "lists a public deck's source in the catalog" do
      deck = whole_deck(visibility: "public")

      split

      expect(deck.source.reload.listed?).to be(true)
    end

    it "takes a public deck out of the catalog" do
      deck = whole_deck(visibility: "public")

      split

      expect(deck.reload.visibility).to eq("private")
    end

    it "reports the sources it lists" do
      deck = whole_deck(visibility: "public")

      expect(split.listed).to eq([deck.source.id])
    end

    it "keeps a source listed already" do
      deck = whole_deck(visibility: "public")
      create(:source_listing, source: deck.source)

      expect { split }.not_to change(SourceListing, :count)
    end

    it "skips a deck whose source has no finished section" do
      snippet = create(:snippet)
      deck = create(:reading_deck, word_list: snippet.word_list)

      expect(split.skipped).to eq([deck.id])
    end

    it "leaves a deck over a list with no source alone" do
      create(:reading_deck)

      expect(split.converted).to be_empty
    end
  end
end
