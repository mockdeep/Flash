# frozen_string_literal: true

require "rails_helper"

RSpec.describe Item do
  it { is_expected.to belong_to(:word_list) }
  it { is_expected.to belong_to(:entry) }

  it { is_expected.to validate_presence_of(:side) }
  it { is_expected.to validate_presence_of(:text) }
  it { is_expected.to validate_presence_of(:entry) }

  describe "uniqueness" do
    it "allows homographs that differ by reading" do
      word_list = create(:word_list)
      create(:item, word_list:, text: "过", reading: "guò")

      expect { create(:item, word_list:, text: "过", reading: "guo") }
        .to change(described_class, :count).by(1)
    end

    it "treats a missing reading as a match" do
      word_list = create(:word_list, language: "es")
      create(:item, word_list:, text: "pasar")

      expect { create(:item, word_list:, text: "pasar") }
        .to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
