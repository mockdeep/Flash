# frozen_string_literal: true

require "rails_helper"

RSpec.describe LanguageDeck do
  describe ".model_name" do
    it "returns the Deck model name for routing" do
      expect(described_class.model_name.route_key).to eq("decks")
    end
  end

  describe "#name" do
    it "reads through the word_list" do
      deck = create(:reading_deck, name: "HSK 1")

      expect(deck.name).to eq("HSK 1")
    end

    it "leaves the deck's own name column empty" do
      deck = create(:reading_deck, name: "HSK 1")

      expect(deck[:name]).to be_nil
    end
  end

  describe "#generates_distractors?" do
    it "is true whatever the pool column says" do
      deck = create(:reading_deck, distractor_pool: "preset")

      expect(deck.generates_distractors?).to be(true)
    end
  end

  describe "#card" do
    it "builds the card for an entry the list selects" do
      card = create(:word, front: "花", back: "flower")

      expect(card.deck.card(card.id))
        .to have_attributes(front: "花", back: "flower")
    end

    it "raises for an entry outside the list" do
      deck = create(:reading_deck)

      expect { deck.card(create(:entry).id) }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#study_pool" do
    it "takes the entries below the level, in list order" do
      deck = create(:reading_deck, level: 1)
      create(:word, :done, deck:, back: "one")
      backs = ["two", "three", "four"]
      backs.each { |back| create(:word, deck:, back:) }

      expect(deck.study_pool(limit: 2).map(&:back)).to eq(["two", "three"])
    end

    it "studies an entry at its weakest sense" do
      deck = create(:reading_deck, level: 1)
      card = create(:word, deck:, back: "he; him")
      create(:skill_score, sense: sense_of(card, "he"), correct_streak: 1)

      expect(deck.study_pool(limit: 5).map(&:correct_streak)).to eq([0])
    end
  end

  def sense_of(card, gloss)
    card.deck.word_list.senses.find_by!(gloss:)
  end

  describe "#all_done?" do
    it "is true when every entry's weakest sense has reached the level" do
      deck = create(:reading_deck, level: 1)
      create(:word, :done, deck:)

      expect(deck.all_done?).to be(true)
    end

    it "is false while an entry sits below the level" do
      deck = create(:reading_deck, level: 1)
      create(:word, :done, deck:)
      create(:word, deck:)

      expect(deck.all_done?).to be(false)
    end
  end

  describe "#backs" do
    it "rejoins every entry's glosses in membership order" do
      deck = create(:reading_deck)
      create(:word, deck:, back: "two;a couple")
      create(:word, deck:, back: "three")

      expect(deck.backs).to contain_exactly("two; a couple", "three")
    end

    it "leaves out the given card" do
      deck = create(:reading_deck)
      create(:word, deck:, back: "two")
      excluded = create(:word, deck:, back: "three")

      expect(deck.backs(except: excluded)).to eq(["two"])
    end

    it "narrows to the words the list files under a category" do
      deck = create(:reading_deck)
      create(:word, deck:, back: "tree", category: "Nature")
      create(:word, deck:, back: "hand", category: "Body")

      expect(deck.backs(category: "Nature")).to eq(["tree"])
    end
  end

  describe "#cards_in_order" do
    it "lists every entry in list order" do
      deck = create(:reading_deck)
      create(:word, deck:, front: "一")
      create(:word, deck:, front: "二")

      expect(deck.cards_in_order.map(&:front)).to eq(["一", "二"])
    end

    it "stops at the limit" do
      deck = create(:reading_deck)
      create(:word, deck:, front: "一")
      create(:word, deck:, front: "二")

      expect(deck.cards_in_order(limit: 1).map(&:front)).to eq(["一"])
    end
  end

  describe "#cards_count" do
    it "counts the list's entries, not its senses" do
      deck = create(:reading_deck)
      create(:word, deck:, back: "he; him")

      expect(deck.cards_count).to eq(1)
    end

    def guest_deck_over(source)
      guest = create(:user, :guest)
      create(:reading_deck, word_list: source.word_list, user: guest)
    end

    it "stops at a guest's limit" do
      stub_const("Deck::GUEST_CARD_LIMIT", 1)
      source = create(:reading_deck)
      create_list(:word, 2, deck: source)

      expect(guest_deck_over(source).cards_count).to eq(1)
    end
  end

  describe "#done_count" do
    it "counts the entries whose weakest sense has reached the level" do
      deck = create(:reading_deck, level: 1)
      create(:word, :done, deck:)
      create(:word, deck:)

      expect(deck.done_count).to eq(1)
    end
  end

  describe "#reading_pairs" do
    it "reads sibling (headword, reading) pairs from the entries" do
      deck = create(:reading_deck)
      create(:word, deck:, front: "两", reading: "liǎng")
      excluded = create(:word, deck:, front: "三", reading: "sān")

      expect(deck.reading_pairs(except: excluded))
        .to contain_exactly(["两", "liǎng"])
    end
  end

  describe "#homograph?" do
    it "is true when the list holds another reading of the headword" do
      card = create(:word, front: "过", reading: "guò")
      create(:word, deck: card.deck, front: "过", reading: "guo")

      expect(card.deck.homograph?(card)).to be(true)
    end

    it "is false when the headword is alone in the list" do
      card = create(:word, front: "过", reading: "guò")

      expect(card.deck.homograph?(card)).to be(false)
    end
  end

  describe "#backs_of" do
    it "rejoins the given entries' glosses as the list shows them" do
      card = create(:word, back: "he; him")

      expect(card.deck.backs_of([card.id])).to eq(["he; him"])
    end

    it "leaves out an entry the list does not hold" do
      card = create(:word, back: "he")

      expect(card.deck.backs_of([create(:entry).id])).to eq([])
    end
  end

  describe "#sense_ids_shown_as" do
    it "finds the member senses of the entry showing that back" do
      card = create(:word, back: "he; him")
      create(:word, deck: card.deck, back: "she")

      expect(card.deck.sense_ids_shown_as("he; him")).to eq(card.sense_ids)
    end

    it "matches the whole back, not one of its glosses" do
      card = create(:word, back: "he; him")

      expect(card.deck.sense_ids_shown_as("he")).to eq([])
    end
  end

  describe "#readings?" do
    it "is true when an entry holds a reading" do
      deck = create(:reading_deck)
      create(:word, deck:, reading: "liǎng")

      expect(deck.readings?).to be(true)
    end

    it "is false when every entry's reading is blank" do
      deck = create(:reading_deck)
      create(:word, deck:, reading: nil)
      create(:word, deck:, reading: "")

      expect(deck.readings?).to be(false)
    end
  end
end
