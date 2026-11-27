# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReadingPlace do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:source) }
  it { is_expected.to belong_to(:snippet_sentence) }
  it { is_expected.to validate_presence_of(:token_index) }

  it do
    create(:reading_place)

    expect(build(:reading_place))
      .to validate_uniqueness_of(:user_id).scoped_to(:source_id)
  end

  it "is removed with its user" do
    place = create(:reading_place)

    expect { place.user.destroy! }.to delete_record(place)
  end

  it "is removed with its source" do
    place = create(:reading_place)

    expect { place.source.destroy! }.to delete_record(place)
  end

  it "is removed with its sentence" do
    place = create(:reading_place)

    expect { place.snippet_sentence.delete }.to delete_record(place)
  end

  describe ".record!" do
    def record_at(sentence, index = 0)
      start = ReadingPages::Start.new(sentence_id: sentence.id, index:)
      source = sentence.source
      described_class.record!(user: default_user, source:, start:)
    end

    it "makes the reader's place in the source" do
      sentence = create(:snippet_sentence)

      record_at(sentence, 2)

      expect(default_user.reading_places.sole)
        .to have_attributes(snippet_sentence: sentence, token_index: 2)
    end

    it "moves a place the reader already has" do
      place = create(:reading_place, user: default_user)
      snippet = place.snippet_sentence.snippet
      sentence = create(:snippet_sentence, snippet:)

      record_at(sentence)

      expect(place.reload.snippet_sentence).to eq(sentence)
    end
  end
end
