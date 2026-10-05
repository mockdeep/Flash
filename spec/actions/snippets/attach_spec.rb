# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::Attach do
  def snippet_using(*senses, snippet: create(:snippet))
    tokens = senses.map { |sense| matched(sense) }
    create(:snippet_sentence, snippet:, tokens: tokens + [{ "text" => "。" }])
    snippet
  end

  def matched(sense)
    { "text" => "爱", "outcome" => "matched", "sense_id" => sense.id }
  end

  describe ".call" do
    it "adds the snippet's senses to its word_list in snippet order" do
      late, early = create_pair(:sense)
      snippet = snippet_using(early, late)

      described_class.call(snippet)

      memberships = snippet.word_list.sense_memberships.order(:position)

      expect(memberships.pluck(:sense_id)).to eq([early.id, late.id])
    end

    it "positions them after the senses the list already holds" do
      snippet = snippet_using(create(:sense))
      create(:sense_membership, word_list: snippet.word_list, position: 4)

      described_class.call(snippet)

      expect(snippet.word_list.sense_memberships.maximum(:position)).to eq(5)
    end

    it "adds a repeated sense once" do
      sense = create(:sense)

      expect { described_class.call(snippet_using(sense, sense)) }
        .to change(SenseMembership, :count).by(1)
    end

    it "leaves a sense the list already holds where it is" do
      sense = create(:sense)
      snippet = snippet_using(sense)
      create(:sense_membership, word_list: snippet.word_list, sense:)

      expect { described_class.call(snippet) }
        .not_to change(SenseMembership, :count)
    end
  end
end
