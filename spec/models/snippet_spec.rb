# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippet do
  it { is_expected.to belong_to(:word_list) }
  it { is_expected.to have_many(:sentences).dependent(:delete_all) }

  it { is_expected.to validate_presence_of(:word_list) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:body) }

  it "orders its sentences by position" do
    snippet = create(:snippet)
    second = create(:snippet_sentence, snippet:, position: 2)
    first = create(:snippet_sentence, snippet:, position: 1)

    expect(snippet.sentences).to eq([first, second])
  end

  it "is removed with its word_list" do
    snippet = create(:snippet)

    expect { snippet.word_list.destroy! }.to delete_record(snippet)
  end
end
