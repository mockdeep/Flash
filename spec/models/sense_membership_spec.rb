# frozen_string_literal: true

require "rails_helper"

RSpec.describe SenseMembership do
  it { is_expected.to belong_to(:sense) }
  it { is_expected.to belong_to(:word_list) }

  it { is_expected.to validate_presence_of(:position) }

  def same_selection(membership)
    build(
      :sense_membership,
      sense: membership.sense,
      word_list: membership.word_list,
    )
  end

  it "selects a sense into a list once" do
    membership = create(:sense_membership)

    expect(same_selection(membership)).not_to be_valid
  end
end
