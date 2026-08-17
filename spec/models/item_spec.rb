# frozen_string_literal: true

require "rails_helper"

RSpec.describe Item do
  it { is_expected.to belong_to(:word_list) }
  it { is_expected.to have_many(:cards).dependent(:destroy) }
  it { is_expected.to have_many(:paired_items).through(:pairings) }
  it { is_expected.to have_many(:distractors).through(:item_distractors) }

  it { is_expected.to validate_presence_of(:side) }
  it { is_expected.to validate_presence_of(:text) }

  describe "#glosses" do
    def pair_back(front, text)
      back = create(:item, :back, word_list: front.word_list, text:)
      create(:pairing, item: front, paired_item: back)
    end

    it "returns paired back texts in authored order" do
      front = create(:item, text: "明白")
      pair_back(front, "understand")
      pair_back(front, "clear")

      expect(front.glosses).to eq(["understand", "clear"])
    end
  end
end
