# frozen_string_literal: true

require "rails_helper"

RSpec.describe Item do
  it { is_expected.to belong_to(:word_list) }
  it { is_expected.to have_many(:cards).dependent(:destroy) }
  it { is_expected.to have_many(:paired_items).through(:pairings) }
  it { is_expected.to have_many(:distractors).through(:item_distractors) }

  it { is_expected.to validate_presence_of(:side) }
  it { is_expected.to validate_presence_of(:text) }

  describe "uniqueness" do
    it "allows homographs that differ by reading" do
      word_list = create(:word_list)
      create(:item, word_list:, text: "过", reading: "guò")

      expect { create(:item, word_list:, text: "过", reading: "guo") }
        .to change(described_class, :count).by(1)
    end

    it "treats a missing reading as a match" do
      word_list = create(:word_list)
      create(:item, :back, word_list:, text: "to pass")

      expect { create(:item, :back, word_list:, text: "to pass") }
        .to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

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
