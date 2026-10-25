# frozen_string_literal: true

require "rails_helper"

RSpec.describe LanguageDeck do
  describe ".model_name" do
    it "returns the Deck model name for routing" do
      expect(described_class.model_name.route_key).to eq("decks")
    end
  end

  # Cards go in through a deck over the whole list; a snippet deck only
  # shows the ones its snippet uses.
  def snippet_deck_of(deck, *cards, **)
    snippet = create(:snippet, word_list: deck.word_list, **)
    create(:snippet_sentence, snippet:, tokens: tokens_for(cards))
    create(:reading_deck, word_list: deck.word_list, snippet:)
  end

  def tokens_for(cards)
    cards.map do |card|
      { "text" => card.front, "sense_id" => Integer(card.id.split("-").first) }
    end
  end

  describe "#name" do
    it "names a snippet deck for its heading" do
      deck = create(:reading_deck, name: "Vampiro")

      expect(snippet_deck_of(deck, heading: "Parte Um").name)
        .to eq("Vampiro · Parte Um")
    end

    it "names a snippet deck without a heading for its place" do
      deck = create(:reading_deck, name: "Vampiro")
      create(:snippet, word_list: deck.word_list)

      expect(snippet_deck_of(deck).name).to eq("Vampiro · 2")
    end

    it "reads through the word_list" do
      deck = create(:reading_deck, name: "HSK 1")

      expect(deck.name).to eq("HSK 1")
    end

    it "leaves the deck's own name column empty" do
      deck = create(:reading_deck, name: "HSK 1")

      expect(deck[:name]).to be_nil
    end
  end

  describe "#script" do
    it "starts in simplified" do
      expect(create(:reading_deck).script).to eq("simplified")
    end

    it "rejects a script it can't study in" do
      deck = build(:reading_deck, script: "pinyin")

      expect(deck).not_to be_valid
    end
  end

  describe "#generates_distractors?" do
    it "is true whatever the pool column says" do
      deck = create(:reading_deck, distractor_pool: "preset")

      expect(deck.generates_distractors?).to be(true)
    end
  end

  describe "#card" do
    it "builds the card holding the given senses" do
      card = create(:language_card, front: "花", back: "flower")

      expect(card.deck.card(card.id))
        .to have_attributes(front: "花", back: "flower")
    end

    it "raises for a sense outside the list" do
      deck = create(:reading_deck)

      expect { deck.card(create(:sense).id.to_s) }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#study_pool" do
    it "takes the entries below the round, in list order" do
      deck = create(:reading_deck, round: 1)
      create(:language_card, :done, deck:, back: "one")
      backs = ["two", "three", "four"]
      backs.each { |back| create(:language_card, deck:, back:) }

      expect(deck.study_pool(limit: 2).map(&:back)).to eq(["two", "three"])
    end

    it "studies an entry at its weakest sense" do
      deck = create(:reading_deck, round: 1)
      card = create(:language_card, deck:, back: "he; him")
      create(:skill_score, sense: sense_of(card, "he"), correct_streak: 1)

      expect(deck.study_pool(limit: 5).map(&:correct_streak)).to eq([0])
    end

    it "leaves out an entry answered correctly today" do
      deck = create(:reading_deck, round: 2)
      create(:language_card, deck:, back: "one").record_correct!
      create(:language_card, deck:, back: "two")

      expect(deck.study_pool(limit: 5).map(&:back)).to eq(["two"])
    end

    it "leaves out an entry with any sense answered correctly today" do
      deck = create(:reading_deck, round: 2)
      card = create(:language_card, deck:, back: "he; him")
      sense = sense_of(card, "he")
      create(:skill_score, sense:, last_correct_at: Time.current)

      expect(deck.study_pool(limit: 5)).to be_empty
    end

    it "practices only the entries answered correctly today" do
      deck = create(:reading_deck, round: 2)
      create(:language_card, deck:, back: "one").record_correct!
      create(:language_card, deck:, back: "two")

      pool = deck.study_pool(limit: 5, practice: true)
      expect(pool.map(&:back)).to eq(["one"])
    end

    it "studies an entry answered correctly before today" do
      deck = create(:reading_deck, round: 2)
      card = create(:language_card, deck:)
      travel_to(1.day.ago) { card.record_correct! }

      expect(deck.study_pool(limit: 5).map(&:id)).to eq([card.id])
    end

    it "counts an entry's views from its scores" do
      deck = create(:reading_deck, round: 1)
      create(:language_card, deck:, view_count: 2)

      expect(deck.study_pool(limit: 5).map(&:view_count)).to eq([2])
    end

    it "counts an entry without scores as unseen" do
      deck = create(:reading_deck, round: 1)
      create(:language_card, deck:)

      expect(deck.study_pool(limit: 5).map(&:view_count)).to eq([0])
    end

    it "keeps a snippet deck to the words its snippet uses" do
      deck = create(:reading_deck)
      used = create(:language_card, deck:, front: "爱")
      create(:language_card, deck:, front: "你")
      snippet_deck = snippet_deck_of(deck, used)

      expect(snippet_deck.study_pool(limit: 10).map(&:front)).to eq(["爱"])
    end

    def titled(deck, front)
      card = create(:language_card, deck:, front:)
      snippet_deck = snippet_deck_of(deck)
      source = snippet_deck.snippet.source
      create(:front_matter, source:, tokens: tokens_for([card]))
      snippet_deck
    end

    it "gives a snippet deck its source's title and author" do
      snippet_deck = titled(create(:reading_deck), "春节")

      expect(snippet_deck.study_pool(limit: 10).map(&:front)).to eq(["春节"])
    end

    it "leaves out another snippet's words" do
      deck = create(:reading_deck)
      snippet_deck_of(deck, create(:language_card, deck:, front: "爱"))
      second = snippet_deck_of(deck, create(:language_card, deck:, front: "你"))

      expect(second.study_pool(limit: 10).map(&:front)).to eq(["你"])
    end
  end

  def sense_of(card, gloss)
    card.deck.word_list.senses.find_by!(gloss:)
  end

  describe "#all_done?" do
    it "is true when every entry's weakest sense has reached the round" do
      deck = create(:reading_deck, round: 1)
      create(:language_card, :done, deck:)

      expect(deck.all_done?).to be(true)
    end

    it "is false while an entry sits below the round" do
      deck = create(:reading_deck, round: 1)
      create(:language_card, :done, deck:)
      create(:language_card, deck:)

      expect(deck.all_done?).to be(false)
    end
  end

  describe "#name_translation" do
    it "adds a snippet's heading translation to its source's" do
      deck = create(:reading_deck)
      create(:source, word_list: deck.word_list, title_translation: "Vampire")
      snippet_deck = snippet_deck_of(deck, heading_translation: "Part One")

      expect(snippet_deck.name_translation).to eq("Vampire · Part One")
    end

    it "is nil with neither translation" do
      deck = create(:reading_deck)

      expect(snippet_deck_of(deck).name_translation).to be_nil
    end
  end

  describe "#catch_up_round!" do
    it "moves on to the round after the weakest entry's streak" do
      deck = create(:reading_deck, round: 1)
      create(:language_card, deck:, correct_streak: 2)
      create(:language_card, deck:, correct_streak: 4)
      deck.catch_up_round!

      expect(deck.reload.round).to eq(3)
    end

    it "keeps the round while an entry sits below it" do
      deck = create(:reading_deck, round: 2)
      create(:language_card, deck:, correct_streak: 1)
      deck.catch_up_round!

      expect(deck.reload.round).to eq(2)
    end
  end

  describe "#not_done_count" do
    it "counts the entries whose weakest sense is below the given round" do
      deck = create(:reading_deck, round: 1)
      create(:language_card, deck:, correct_streak: 1)
      create(:language_card, deck:, correct_streak: 2)

      expect(deck.not_done_count(2)).to eq(1)
    end
  end

  describe "#backs" do
    it "rejoins every entry's glosses in membership order" do
      deck = create(:reading_deck)
      create(:language_card, deck:, back: "two;a couple")
      create(:language_card, deck:, back: "three")

      expect(deck.backs).to contain_exactly("two; a couple", "three")
    end

    it "leaves out the given card" do
      deck = create(:reading_deck)
      create(:language_card, deck:, back: "two")
      excluded = create(:language_card, deck:, back: "three")

      expect(deck.backs(except: excluded)).to eq(["two"])
    end

    it "narrows to the words the list files under a category" do
      deck = create(:reading_deck)
      create(:language_card, deck:, back: "tree", category: "Nature")
      create(:language_card, deck:, back: "hand", category: "Body")

      expect(deck.backs(category: "Nature")).to eq(["tree"])
    end
  end

  describe "#cards_in_order" do
    it "lists every entry in list order" do
      deck = create(:reading_deck)
      create(:language_card, deck:, front: "一")
      create(:language_card, deck:, front: "二")

      expect(deck.cards_in_order.map(&:front)).to eq(["一", "二"])
    end

    it "stops at the limit" do
      deck = create(:reading_deck)
      create(:language_card, deck:, front: "一")
      create(:language_card, deck:, front: "二")

      expect(deck.cards_in_order(limit: 1).map(&:front)).to eq(["一"])
    end
  end

  describe "#cards_count" do
    it "counts the list's entries, not its senses" do
      deck = create(:reading_deck)
      create(:language_card, deck:, back: "he; him")

      expect(deck.cards_count).to eq(1)
    end

    def guest_deck_over(source)
      guest = create(:user, :guest)
      create(:reading_deck, word_list: source.word_list, user: guest)
    end

    it "stops at a guest's limit" do
      stub_const("Deck::GUEST_CARD_LIMIT", 1)
      source = create(:reading_deck)
      create_list(:language_card, 2, deck: source)

      expect(guest_deck_over(source).cards_count).to eq(1)
    end
  end

  describe "#done_count" do
    it "counts the entries whose weakest sense has reached the round" do
      deck = create(:reading_deck, round: 1)
      create(:language_card, :done, deck:)
      create(:language_card, deck:)

      expect(deck.done_count).to eq(1)
    end
  end

  describe "#reading_pairs" do
    it "reads sibling (headword, reading) pairs from the entries" do
      deck = create(:reading_deck)
      create(:language_card, deck:, front: "两", reading: "liǎng")
      excluded = create(:language_card, deck:, front: "三", reading: "sān")

      expect(deck.reading_pairs(except: excluded))
        .to contain_exactly(["两", "liǎng"])
    end
  end

  describe "#homograph?" do
    it "is true when the list holds another reading of the headword" do
      card = create(:language_card, front: "过", reading: "guò")
      create(:language_card, deck: card.deck, front: "过", reading: "guo")

      expect(card.deck.homograph?(card)).to be(true)
    end

    it "matches the headword whatever the article" do
      card = create(:language_card, front: "capital", reading: "a")
      create(:language_card, deck: card.deck, front: "capital", reading: "b")
      Entry.find_by!(reading: "a").update!(language: "pt", article: "a")

      expect(card.deck.homograph?(card.deck.card(card.id))).to be(true)
    end

    it "is false when the headword is alone in the list" do
      card = create(:language_card, front: "过", reading: "guò")

      expect(card.deck.homograph?(card)).to be(false)
    end
  end

  describe "#backs_of" do
    it "rejoins the glosses of the cards holding the senses" do
      card = create(:language_card, back: "he; him")

      expect(card.deck.backs_of(card.sense_ids.take(1))).to eq(["he; him"])
    end

    it "leaves out a sense the list does not hold" do
      card = create(:language_card, back: "he")

      expect(card.deck.backs_of([create(:sense).id])).to eq([])
    end
  end

  describe "#sense_ids_shown_as" do
    it "finds the member senses of the entry showing that back" do
      card = create(:language_card, back: "he; him")
      create(:language_card, deck: card.deck, back: "she")

      expect(card.deck.sense_ids_shown_as("he; him")).to eq(card.sense_ids)
    end

    it "matches the whole back, not one of its glosses" do
      card = create(:language_card, back: "he; him")

      expect(card.deck.sense_ids_shown_as("he")).to eq([])
    end

    it "leaves out an entry whose back is only part of the text" do
      card = create(:language_card, back: "he; him")
      create(:language_card, deck: card.deck, back: "he")

      expect(card.deck.sense_ids_shown_as("he; him")).to eq(card.sense_ids)
    end
  end

  describe "#readings?" do
    it "is true when an entry holds a reading" do
      deck = create(:reading_deck)
      create(:language_card, deck:, reading: "liǎng")

      expect(deck.readings?).to be(true)
    end

    it "is false when every entry's reading is blank" do
      deck = create(:reading_deck)
      create(:language_card, deck:, reading: nil)
      create(:language_card, deck:, reading: "")

      expect(deck.readings?).to be(false)
    end
  end

  describe "in traditional" do
    def split_gan(script:)
      deck = create(:reading_deck, script:)
      word = { deck:, front: "干", reading: "gān" }
      create(:language_card, **word, back: "dry", traditional: "乾")
      create(:language_card, **word, back: "to concern", traditional: "干")
      deck
    end

    it "makes a card per spelling of an entry" do
      deck = split_gan(script: "traditional")

      expect(deck.cards_in_order.map(&:back)).to eq(["dry", "to concern"])
    end

    it "keeps an entry's spellings on one card in simplified" do
      deck = split_gan(script: "simplified")

      expect(deck.cards_in_order.map(&:back)).to eq(["dry; to concern"])
    end

    it "finds a spelling's card by its senses" do
      deck = split_gan(script: "traditional")
      card = deck.cards_in_order.last

      expect(deck.card(card.id).back).to eq("to concern")
    end

    it "spells a sense with no traditional form as its headword" do
      deck = create(:reading_deck, script: "traditional")
      create(:language_card, deck:, front: "花")

      expect(deck.hanzi_chars).to eq("花")
    end

    it "reads its characters from the traditional forms" do
      deck = split_gan(script: "traditional")

      expect(deck.hanzi_chars).to eq("乾干")
    end

    it "finds homographs by the traditional form" do
      deck = split_gan(script: "traditional")
      card = create(:language_card, deck:, front: "乾", reading: "qián")

      expect(deck.homograph?(card)).to be(true)
    end

    def traditional_guest_deck_over(source)
      guest = create(:user, :guest)
      word_list = source.word_list
      create(:reading_deck, word_list:, user: guest, script: "traditional")
    end

    it "caps a guest's deck by card" do
      stub_const("Deck::GUEST_CARD_LIMIT", 1)
      source = split_gan(script: "traditional")

      expect(traditional_guest_deck_over(source).cards_count).to eq(1)
    end
  end
end
