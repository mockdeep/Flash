# frozen_string_literal: true

require "rails_helper"

RSpec.describe WordLists::RepairGloss do
  def front(word_list, text, *glosses)
    item = create(:item, word_list:, text:)
    glosses.each { |gloss| pair(item, gloss) }
    item
  end

  def pair(item, gloss)
    back = item.word_list.items.find_or_create_by!(side: "Back", text: gloss)
    create(:pairing, item:, paired_item: back)
  end

  def repair(word_list, dry_run: true, **args)
    defaults = { front: "a gente", from: "the people", to: ["we", "us"] }
    described_class.call(word_list:, dry_run:, **defaults, **args)
  end

  def repair_orange(word_list, dry_run: true)
    repair(
      word_list,
      dry_run:,
      front: "a cor de laranja",
      from: "the orange",
      to: ["the color orange"],
    )
  end

  it "replaces the gloss with the new ones, in order" do
    word_list = create(:word_list, language: "pt")
    item = front(word_list, "a gente", "the people")

    repair(word_list, dry_run: false)

    expect(item.reload.glosses).to eq(["we", "us"])
  end

  it "keeps the replaced gloss's place among the front's other glosses" do
    word_list = create(:word_list, language: "pt")
    item = front(word_list, "a gente", "the people", "the folks")

    repair(word_list, dry_run: false)

    expect(item.reload.glosses).to eq(["we", "the folks", "us"])
  end

  it "leaves a shared back item glossing its other front" do
    word_list = create(:word_list, language: "pt")
    front(word_list, "a cor de laranja", "the orange")
    fruit = front(word_list, "a laranja", "the orange")

    repair_orange(word_list, dry_run: false)

    expect(fruit.reload.glosses).to eq(["the orange"])
  end

  it "reuses a back item that already holds the new gloss" do
    word_list = create(:word_list, language: "pt")
    item = front(word_list, "a gente", "the people")
    existing = front(word_list, "nós", "we")

    repair(word_list, dry_run: false)

    expect(item.reload.paired_items).to include(existing.paired_items.first)
  end

  it "writes nothing on a dry run" do
    word_list = create(:word_list, language: "pt")
    item = front(word_list, "a gente", "the people")

    repair(word_list)

    expect(item.reload.glosses).to eq(["the people"])
  end

  it "reports the fronts still sharing the old back item" do
    word_list = create(:word_list, language: "pt")
    front(word_list, "a cor de laranja", "the orange")
    front(word_list, "a laranja", "the orange")

    report = repair_orange(word_list)

    expect(report.shared_with).to eq(["a laranja"])
  end

  it "raises when the front does not carry the gloss to replace" do
    word_list = create(:word_list, language: "pt")
    front(word_list, "a gente", "the folks")

    expect { repair(word_list) }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
