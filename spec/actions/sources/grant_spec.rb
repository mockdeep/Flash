# frozen_string_literal: true

require "rails_helper"

RSpec.describe Sources::Grant do
  # Grant gives a deck for the source's first section, so it needs one.
  def studyable_source = create(:snippet, :finished).source

  def grant(username, source: studyable_source)
    described_class.call(source:, username:)
  end

  describe ".call" do
    it "lets the user read the source" do
      source = studyable_source
      user = create(:user, username: "reader")

      described_class.call(source:, username: "reader")

      expect(source.readable_by?(user)).to be(true)
    end

    it "gives the user a reading deck over the source's list" do
      source = studyable_source
      user = create(:user, username: "reader")

      described_class.call(source:, username: "reader")

      expect(user.decks.sole)
        .to have_attributes(type: "ReadingDeck", word_list: source.word_list)
    end

    it "starts the user's deck at the source's first section" do
      snippet = create(:snippet, :finished)
      user = create(:user, username: "reader")

      described_class.call(source: snippet.source, username: "reader")

      expect(user.decks.sole.snippet).to eq(snippet)
    end

    it "keeps the deck the user already has over the list" do
      source = studyable_source
      deck = create(:user).deck_starting(source)
      username = deck.user.username

      expect { described_class.call(source:, username:) }
        .not_to change(Deck, :count)
    end

    it "lets a reader in only once" do
      reader = create(:source_reader, source: studyable_source)
      username = reader.user.username

      expect { described_class.call(source: reader.source, username:) }
        .not_to change(SourceReader, :count)
    end

    it "returns a success result" do
      create(:user, username: "reader")

      expect(grant("reader")).to be_success
    end

    context "when no user has the username" do
      it "returns a failure result" do
        expect(grant("nobody")).not_to be_success
      end

      it "names the username it could not find" do
        expect(grant("nobody").record.errors.full_messages)
          .to eq(["No user named nobody"])
      end
    end

    it "refuses a guest" do
      guest = create(:user, :guest)

      expect(grant(guest.username)).not_to be_success
    end
  end
end
