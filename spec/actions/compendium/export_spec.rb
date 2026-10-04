# frozen_string_literal: true

require "rails_helper"

RSpec.describe Compendium::Export do
  it "writes a CSV per table with a header of sorted columns" do
    snapshot = export

    expect(snapshot.path("senses").readlines.first)
      .to eq("created_at,entry_id,gloss,id,updated_at\n")
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
end
