# frozen_string_literal: true

require "rails_helper"

RSpec.describe Item do
  it { is_expected.to belong_to(:data_set) }
  it { is_expected.to have_many(:cards).dependent(:nullify) }
  it { is_expected.to have_many(:paired_items).through(:pairings) }
  it { is_expected.to have_many(:distractors).through(:item_distractors) }

  it { is_expected.to validate_presence_of(:side) }
  it { is_expected.to validate_presence_of(:text) }
end
