# frozen_string_literal: true

RSpec.describe StudyPlace do
  def seen(sentence, **)
    sense_id = sentence.tokens.first["sense_id"]
    create(:skill_score, sense_id:, view_count: 1, **)
  end

  it "is none for a deck without a text" do
    expect(described_class.new(create(:deck)).page).to be_nil
  end

  it "is none before any word is seen" do
    deck, = two_page_deck

    expect(described_class.new(deck).page).to be_nil
  end

  it "is the furthest page a seen word first appears on" do
    deck, second = two_page_deck
    seen(deck.snippets.first.sentences.first)
    seen(second)

    expect(described_class.new(deck).page).to eq(2)
  end

  it "counts only the learner's own words" do
    deck, second = two_page_deck
    seen(second, user: create(:user))

    expect(described_class.new(deck).page).to be_nil
  end

  it "is none for a text the learner may not read" do
    deck, second = two_page_deck
    deck.word_list.update!(user: create(:user))
    seen(second)

    expect(described_class.new(deck).page).to be_nil
  end

  def with_memory_cache
    original = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    yield
  ensure
    Rails.cache = original
  end

  # The place, worked out once, then again after the first sentence comes
  # to use the second's word.
  def place_after_text_changes
    deck, second = two_page_deck
    seen(second)
    with_memory_cache do
      described_class.new(deck).page
      deck.snippets.first.sentences.first.update!(tokens: second.tokens)
      described_class.new(deck).page
    end
  end

  it "works the pages out again once the text changes" do
    expect(place_after_text_changes).to eq(1)
  end
end
