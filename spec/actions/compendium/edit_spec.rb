# frozen_string_literal: true

require "rails_helper"

RSpec.describe Compendium::Edit do
  def love_entry(reading: "ài") = create(:entry, headword: "爱", reading:)

  def sentence_with(*tokens) = create(:snippet_sentence, tokens:)

  describe ".add" do
    def add(gloss: "to love")
      described_class.add(headword: "爱", reading: "ài", gloss:)
    end

    it "creates the sense under the headword and reading" do
      expect(add.entry).to have_attributes(headword: "爱", reading: "ài")
    end

    it "uses the entry for the reading when there is one" do
      entry = love_entry

      expect(add.entry).to eq(entry)
    end

    it "reuses a sense the entry already holds under the gloss" do
      sense = create(:sense, entry: love_entry, gloss: "to love")

      expect(add).to eq(sense)
    end
  end

  describe ".revise" do
    it "changes the gloss" do
      sense = create(:sense, gloss: "to spend / flower")

      expect { described_class.revise(sense, gloss: "flower") }
        .to change_record(sense, :gloss).to("flower")
    end

    it "moves the sense to the entry for a new reading" do
      sense = create(:sense, entry: love_entry)
      other = love_entry(reading: "ǎi")
      described_class.revise(sense, reading: "ǎi")

      expect(sense.reload.entry).to eq(other)
    end

    it "removes an entry the move leaves without senses" do
      entry = love_entry
      sense = create(:sense, entry:)

      expect { described_class.revise(sense, reading: "ǎi") }
        .to delete_record(entry)
    end

    it "keeps an entry that still holds senses" do
      entry = love_entry
      sense, = create_pair(:sense, entry:)

      expect { described_class.revise(sense, reading: "ǎi") }
        .not_to delete_record(entry)
    end
  end

  describe ".remove" do
    it "deletes a sense nothing uses" do
      sense = create(:sense)

      expect { described_class.remove(sense) }.to delete_record(sense)
    end

    it "removes an entry left without senses" do
      sense = create(:sense)

      expect { described_class.remove(sense) }.to delete_record(sense.entry)
    end

    it "keeps an entry that still holds senses" do
      sense, = create_pair(:sense, entry: love_entry)

      expect { described_class.remove(sense) }.not_to delete_record(sense.entry)
    end

    it "refuses a sense a token points at" do
      sense = create(:sense)
      sentence_with({ "text" => "爱", "sense_id" => sense.id })

      expect { described_class.remove(sense) }
        .to raise_error(described_class::Refused, /snippet tokens/)
    end

    it "refuses a sense a list holds" do
      sense = create(:sense_membership).sense

      expect { described_class.remove(sense) }
        .to raise_error(described_class::Refused, /word lists/)
    end

    it "refuses a sense with learner progress" do
      sense = create(:skill_score).sense

      expect { described_class.remove(sense) }
        .to raise_error(described_class::Refused, /learner progress/)
    end

    it "refuses a sense with distractor history" do
      sense = create(:sense_distractor).sense

      expect { described_class.remove(sense) }
        .to raise_error(described_class::Refused, /distractor history/)
    end
  end

  describe ".attach" do
    def attach_with_category(category)
      described_class.attach(create(:sense), create(:word_list), category:)
    end

    it "puts the sense into the list after the senses it holds" do
      list = create(:sense_membership, position: 4).word_list
      membership = described_class.attach(create(:sense), list)

      expect(membership.position).to eq(5)
    end

    it "files it under the category given" do
      expect(attach_with_category("noun").category).to eq("noun")
    end

    it "leaves a sense the list already holds where it is" do
      membership = create(:sense_membership)

      expect { described_class.attach(membership.sense, membership.word_list) }
        .not_to change(SenseMembership, :count)
    end
  end

  describe ".detach" do
    it "takes the sense out of the list" do
      membership = create(:sense_membership)

      expect { described_class.detach(membership.sense, membership.word_list) }
        .to delete_record(membership)
    end
  end
end
