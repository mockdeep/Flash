# frozen_string_literal: true

require "rails_helper"

RSpec.describe Item do
  it { is_expected.to belong_to(:data_set) }
  it { is_expected.to have_many(:cards).dependent(:destroy) }
  it { is_expected.to have_many(:paired_items).through(:pairings) }
  it { is_expected.to have_many(:distractors).through(:item_distractors) }

  it { is_expected.to validate_presence_of(:side) }
  it { is_expected.to validate_presence_of(:text) }

  describe "#reverse_glosses" do
    def pair(front_text, back)
      front = create(:item, data_set: back.data_set, text: front_text)
      create(:pairing, item: front, paired_item: back)
    end

    it "returns paired item texts in authored order" do
      back = create(:item, :back, text: "understand")
      pair("明白", back)
      pair("清楚", back)

      expect(back.reverse_glosses).to eq(["明白", "清楚"])
    end
  end
end
