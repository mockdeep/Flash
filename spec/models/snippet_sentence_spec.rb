# frozen_string_literal: true

require "rails_helper"

RSpec.describe SnippetSentence do
  it { is_expected.to belong_to(:snippet) }

  it { is_expected.to validate_presence_of(:snippet) }
  it { is_expected.to validate_presence_of(:body) }
  it { is_expected.to validate_presence_of(:position) }

  it "keeps positions unique within a snippet" do
    sentence = create(:snippet_sentence)
    snippet, position = sentence.values_at(:snippet, :position)

    expect { create(:snippet_sentence, snippet:, position:) }
      .to raise_error(ActiveRecord::RecordNotUnique)
  end
end
