# frozen_string_literal: true

require "rails_helper"

RSpec.describe Compendium::Export do
  it "writes a CSV per table with a header of sorted columns" do
    snapshot = export

    expect(snapshot.path("senses").readlines.first)
      .to eq("created_at,entry_id,gloss,id,traditional,updated_at\n")
  end

  it "writes rows in id order" do
    second = create(:entry, headword: "二")
    first = create(:entry, headword: "一", id: second.id - 1)

    ids = CSV.read(export.path("entries"), headers: true).pluck("id")

    expect(ids).to eq([first.id, second.id].map(&:to_s))
  end

  it "leaves out word_list owners" do
    create(:word_list)

    headers = CSV.read(export.path("word_lists"), headers: true).headers

    expect(headers).not_to include("user_id")
  end

  context "when given only some tables and columns" do
    def export_entry_ids(dir)
      snapshot = Compendium::Snapshot.new(dir)

      described_class.call(connection, snapshot, only: { "entries" => ["id"] })
    end

    it "writes just those columns" do
      expect(export_entry_ids(Dir.mktmpdir).path("entries").readlines)
        .to eq(["id\n"])
    end

    it "leaves the other tables unwritten" do
      expect(export_entry_ids(Dir.mktmpdir).path("senses")).not_to exist
    end

    it "returns a snapshot of just those tables" do
      expect(export_entry_ids(Dir.mktmpdir).tables).to eq(["entries"])
    end

    it "skips a column the database no longer has" do
      only = { "entries" => ["id", "dropped"] }
      snapshot = Compendium::Snapshot.new(Dir.mktmpdir)
      described_class.call(connection, snapshot, only:)

      expect(snapshot.path("entries").readlines).to eq(["id\n"])
    end

    it "skips a table the database no longer has" do
      only = { "entries" => ["id"], "dropped" => ["id"] }
      snapshot = Compendium::Snapshot.new(Dir.mktmpdir)

      expect(described_class.call(connection, snapshot, only:).tables)
        .to eq(["entries"])
    end
  end
end
