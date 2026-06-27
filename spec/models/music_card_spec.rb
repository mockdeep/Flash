# frozen_string_literal: true

require "rails_helper"

RSpec.describe MusicCard do
  # Note-format validation now lives at ingest (Decks::CreateMusic), since the
  # card is a thin item_id+progress anchor -- see create_music_spec.

  describe ".model_name" do
    it "returns the Card model name for routing" do
      expect(described_class.model_name.route_key).to eq("cards")
    end
  end
end
