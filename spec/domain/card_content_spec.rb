# frozen_string_literal: true

require "rails_helper"

RSpec.describe CardContent do
  it "reads the front from the item" do
    card = create(:card, front: "明白")

    expect(described_class.new(card).front).to eq("明白")
  end

  it "rejoins a semicolon back from the item's glosses" do
    card = create(:card, back: "understand;clear")

    expect(described_class.new(card).back).to eq("understand; clear")
  end

  it "reads the distractors from the item" do
    card = create(:card, distractors: ["happy", "run"])

    expect(described_class.new(card).distractors)
      .to contain_exactly("happy", "run")
  end

  it "reads reading and category from the item" do
    card = create(:card, reading: "míngbai")

    expect(described_class.new(card))
      .to have_attributes(reading: "míngbai", category: "General")
  end

  it "reads the example pair from the item" do
    card = create(:card, example_front: "ef", example_back: "eb")

    expect(described_class.new(card))
      .to have_attributes(example_front: "ef", example_back: "eb")
  end
end
