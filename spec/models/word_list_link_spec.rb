# frozen_string_literal: true

require "rails_helper"

RSpec.describe WordListLink do
  it { is_expected.to belong_to(:word_list) }
  it { is_expected.to belong_to(:linked_word_list).class_name("WordList") }

  it { is_expected.to validate_presence_of(:word_list) }
  it { is_expected.to validate_presence_of(:linked_word_list) }
  it { is_expected.to validate_presence_of(:strength) }

  it "stores a pair of lists once" do
    expect(create(:word_list_link))
      .to validate_uniqueness_of(:linked_word_list_id).scoped_to(:word_list_id)
  end

  it "takes the list with the lower id first" do
    link = create(:word_list_link)
    backwards = described_class.new(
      word_list: link.linked_word_list, linked_word_list: link.word_list,
    )

    expect(backwards).not_to be_valid
  end

  it "cannot join a list to itself" do
    list = create(:word_list)

    expect(build(:word_list_link, word_list: list, linked_word_list: list))
      .not_to be_valid
  end

  it "goes when either of its lists does" do
    link = create(:word_list_link)

    expect { link.linked_word_list.destroy! }
      .to change(described_class, :count).by(-1)
  end
end
