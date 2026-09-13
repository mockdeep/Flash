# frozen_string_literal: true

require "rails_helper"

RSpec.describe WordLists::CanonicalizeEntries do
  def list(language = "zh")
    create(:word_list, language:)
  end

  # A Front item as it stood before the backfill: no entry yet, which the
  # model no longer allows, so validation is bypassed.
  def front(word_list, text, reading = nil)
    build(:item, word_list:, text:, reading:, entry: nil)
      .tap { |item| item.save!(validate: false) }
  end

  def canonicalize
    described_class.call(dry_run: false)
  end

  # Two Mandarin lists teaching the same word, and a Spanish list.
  def two_lists_sharing_a_word
    front(list, "过", "guò")
    front(list, "过", "guò")
    front(list("es"), "el pelo")
  end

  it "links each front item to an entry carrying its text and reading" do
    item = front(list, "过", "guò")

    canonicalize

    expect(item.reload.entry).to have_attributes(
      language: "zh", headword: "过", reading: "guò",
    )
  end

  it "shares one entry between lists teaching the same word" do
    one = front(list, "过", "guò")
    two = front(list, "过", "guò")

    canonicalize

    expect(one.reload.entry).to eq(two.reload.entry)
  end

  it "keeps two readings of one written form as two entries" do
    one = front(list, "过", "guò")
    two = front(list, "过", "guo")

    canonicalize

    expect(one.reload.entry).not_to eq(two.reload.entry)
  end

  it "treats missing readings as equal" do
    one = front(list("es"), "el pelo")
    two = front(list("es"), "el pelo")

    canonicalize

    expect(one.reload.entry).to eq(two.reload.entry)
  end

  it "keeps the same spelling in two languages apart" do
    one = front(list("es"), "no")
    two = front(list("it"), "no")

    canonicalize

    expect(one.reload.entry).not_to eq(two.reload.entry)
  end

  it "leaves back items alone" do
    back = create(:item, :back, word_list: list, text: "to pass")

    canonicalize

    expect(back.reload.entry).to be_nil
  end

  it "writes nothing on a dry run" do
    item = front(list, "过", "guò")

    described_class.call

    expect([Entry.count, item.reload.entry]).to eq([0, nil])
  end

  it "reports what it did and the merges per language" do
    two_lists_sharing_a_word

    expect(canonicalize).to have_attributes(
      entries: 2, linked: 3, unlinked: 0, mismatched: 0, merged: { "zh" => 1 },
    )
  end

  it "finishes a partial run without duplicating" do
    front(list, "过", "guò").then { canonicalize }
    front(list, "过", "guò")

    expect(canonicalize).to have_attributes(entries: 0, linked: 1)
  end
end
