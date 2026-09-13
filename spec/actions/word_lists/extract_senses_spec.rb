# frozen_string_literal: true

require "rails_helper"

RSpec.describe WordLists::ExtractSenses do
  # A card in its own deck and list; two calls with the same front and
  # reading share an entry, as the entries backfill left production.
  def card(**attrs)
    create(:reading_card, front: "花", reading: "huā", **attrs)
  end

  def extract
    described_class.call(dry_run: false)
  end

  def senses_of(card)
    card.deck.word_list.senses.order("sense_memberships.position")
  end

  it "creates one sense per gloss under the front's entry" do
    flower = card(back: "flower;blossom")

    extract

    expect(senses_of(flower)).to all(have_attributes(entry: flower.entry))
      .and(satisfy { |senses| senses.map(&:gloss) == ["flower", "blossom"] })
  end

  it "shares a sense between lists teaching the same gloss" do
    one = card(back: "flower")
    two = card(back: "flower")

    extract

    expect(senses_of(one)).to eq(senses_of(two))
  end

  it "keeps different glosses of one entry as different senses" do
    one = card(back: "flower")
    two = card(back: "to spend")

    extract

    expect(senses_of(one)).not_to eq(senses_of(two))
  end

  it "rejoins a card's glosses in today's order" do
    flower = card(back: "to spend;flower;blossom")

    extract

    expect(senses_of(flower).map(&:gloss).join("; ")).to eq(flower.back)
  end

  it "files the front's category on the membership" do
    flower = card(back: "flower", category: "Nature")

    extract

    expect(flower.deck.word_list.sense_memberships.sole.category)
      .to eq("Nature")
  end

  it "attaches the front's example to every sense it pairs to" do
    card(back: "flower;blossom", example_front: "一朵花", example_back: "A flower")

    extract

    expect(SenseExample.pluck(:sentence, :translation))
      .to eq([["一朵花", "A flower"]] * 2)
  end

  it "skips a front without an example" do
    card(back: "flower")

    extract

    expect(SenseExample.count).to eq(0)
  end

  it "writes nothing on a dry run" do
    card(back: "flower")

    described_class.call

    expect([Sense.count, SenseMembership.count]).to eq([0, 0])
  end

  def clean_report
    have_attributes(
      senses: 2,
      memberships: 3,
      examples: 2,
      unmapped_pairings: 0,
      back_mismatches: 0,
      multi_example_senses: 0,
    )
  end

  it "reports what it did and that every back rejoins unchanged" do
    card(back: "flower;blossom", example_front: "一朵花", example_back: "A")
    card(back: "flower")

    expect(extract).to clean_report
  end

  it "reports a sense that collected two different examples" do
    card(back: "flower", example_front: "一朵花", example_back: "A")
    card(back: "flower", example_front: "两朵花", example_back: "B")

    expect(extract).to have_attributes(examples: 2, multi_example_senses: 1)
  end

  it "finishes a partial run without duplicating" do
    card(back: "flower").then { extract }
    card(back: "flower;blossom")

    expect(extract).to have_attributes(senses: 1, memberships: 2)
  end
end
