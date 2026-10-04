# frozen_string_literal: true

require "rails_helper"

RSpec.describe Compendium::Load do
  def clear_compendium
    Compendium::TABLES.reverse_each do |table|
      connection.exec("DELETE FROM #{table}")
    end
  end

  it "fills the tables from the snapshot, ids included" do
    sense = create(:sense)
    snapshot = export
    clear_compendium

    described_class.call(connection, snapshot, owner_id: default_user.id)

    expect(Sense.find(sense.id).gloss).to eq(sense.gloss)
  end

  it "gives every word_list to the owner" do
    list = create(:word_list, user: create(:user))
    snapshot = export
    clear_compendium

    described_class.call(connection, snapshot, owner_id: default_user.id)

    expect(WordList.find(list.id).user).to eq(default_user)
  end

  it "moves id sequences past the loaded ids" do
    entry = create(:entry, id: 1_000_000)
    snapshot = export
    clear_compendium

    described_class.call(connection, snapshot, owner_id: default_user.id)

    expect(create(:entry).id).to be > entry.id
  end
end
