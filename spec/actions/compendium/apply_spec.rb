# frozen_string_literal: true

require "rails_helper"

RSpec.describe Compendium::Apply do
  def apply(snapshot, owner_id: default_user.id)
    described_class.call(connection, snapshot, owner_id:)
  end

  it "adds rows only in the snapshot" do
    entry = create(:entry)
    snapshot = export
    entry.delete

    apply(snapshot)

    expect(Entry.exists?(entry.id)).to be(true)
  end

  it "updates rows that differ from the snapshot" do
    sense = create(:sense, gloss: "to love")
    snapshot = export
    sense.update!(gloss: "changed")

    expect { apply(snapshot) }
      .to change_record(sense, :gloss).from("changed").to("to love")
  end

  it "deletes rows missing from the snapshot" do
    snapshot = export
    sense = create(:sense)

    expect { apply(snapshot) }.to delete_record(sense)
  end

  it "deletes children before their parents" do
    snapshot = export
    sense = create(:sense)

    expect { apply(snapshot) }.to delete_record(sense.entry)
  end

  it "reports the rows it added" do
    entry = create(:entry)
    snapshot = export
    entry.delete

    expect(apply(snapshot).changes["entries"][:added]).to eq(1)
  end

  it "reports the rows it updated" do
    sense = create(:sense)
    snapshot = export
    sense.update!(gloss: "changed")

    expect(apply(snapshot).changes["senses"][:updated]).to eq(1)
  end

  it "reports the rows it deleted" do
    snapshot = export
    create(:entry)

    expect(apply(snapshot).changes["entries"][:deleted]).to eq(1)
  end

  it "reports learner progress the deletions take" do
    snapshot = export
    create(:skill_score)

    expect(apply(snapshot).losses["skill_scores"]).to eq(1)
  end

  it "reports distractor history the deletions take" do
    snapshot = export
    create(:sense_distractor)

    expect(apply(snapshot).losses["sense_distractors"]).to eq(1)
  end

  it "keeps the owner of a list that exists" do
    list = create(:word_list)
    snapshot = export

    expect { apply(snapshot, owner_id: create(:user).id) }
      .not_to change_record(list, :user_id)
  end

  it "gives a new list to the owner" do
    list = create(:word_list, user: create(:user))
    snapshot = export
    list.delete

    apply(snapshot, owner_id: default_user.id)

    expect(WordList.find(list.id).user).to eq(default_user)
  end

  it "refuses a snapshot whose columns differ from the table's" do
    snapshot = export
    path = snapshot.path("entries")
    path.write(path.read.sub("headword", "word"))

    expect { apply(snapshot) }.to raise_error(PG::BadCopyFileFormat)
  end

  it "describes the changes as text" do
    snapshot = export
    create(:entry)

    expect(apply(snapshot).to_s)
      .to include("entries: 0 added, 0 updated, 1 deleted")
  end
end
