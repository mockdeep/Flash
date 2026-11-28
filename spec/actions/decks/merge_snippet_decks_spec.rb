# frozen_string_literal: true

require "rails_helper"

RSpec.describe Decks::MergeSnippetDecks do
  # The default user's decks over two snippets of one source, the second
  # studied most recently.
  def section_decks(**second)
    snippets = create_list(:snippet, 2, :finished, source: create(:source))
    [
      section_deck(snippets.first, last_studied_at: 2.days.ago),
      section_deck(snippets.last, last_studied_at: 1.day.ago, **second),
    ]
  end

  def section_deck(snippet, **)
    create(:reading_deck, word_list: snippet.word_list, snippet:, **)
  end

  it "keeps the most recently studied deck" do
    _, latest = section_decks

    described_class.call

    expect(default_user.decks).to eq([latest])
  end

  it "makes the deck kept cover the whole source" do
    _, latest = section_decks

    described_class.call

    expect(latest.reload.snippet).to be_nil
  end

  it "keeps the goal settings of the deck kept" do
    _, latest = section_decks(study_goal: 12)

    described_class.call

    expect(latest.reload.study_goal).to eq(12)
  end

  it "keeps the study days of the deck kept" do
    _, latest = section_decks
    day = latest.study_days.today

    expect { described_class.call }.not_to delete_record(day)
  end

  it "removes the study days of the decks removed" do
    older, = section_decks
    day = older.study_days.today

    expect { described_class.call }.to delete_record(day)
  end

  it "starts the deck kept on round 1" do
    _, latest = section_decks(round: 3)

    expect { described_class.call }.to change_record(latest, :round).to(1)
  end

  it "keeps a deck never studied when it is the newest" do
    older, latest = section_decks
    [older, latest].each { it.update!(last_studied_at: nil) }

    described_class.call

    expect(default_user.decks).to eq([latest])
  end

  it "takes over a removed deck's share link" do
    older, latest = section_decks
    token = older.tap(&:generate_share_token!).share_token

    expect { described_class.call }
      .to change_record(latest, :share_token).to(token)
  end

  it "keeps its own share link" do
    older, latest = section_decks
    [older, latest].each(&:generate_share_token!)
    token = latest.share_token

    expect { described_class.call }.not_to change_record(latest, :share_token)
      .from(token)
  end

  it "stays in the catalog when a removed deck was there" do
    older, latest = section_decks
    older.update!(visibility: "public")

    expect { described_class.call }
      .to change_record(latest, :visibility).to("public")
  end

  it "folds in a deck over the whole source" do
    older, = section_decks
    create(:reading_deck, word_list: older.word_list, snippet: nil)

    described_class.call

    expect(default_user.decks.count).to eq(1)
  end

  it "leaves a deck over a whole source alone" do
    source = create(:source)
    deck = create(:reading_deck, word_list: source.word_list, round: 2)

    expect { described_class.call }.not_to change_record(deck, :round)
  end

  it "leaves each user's decks apart" do
    older, = section_decks
    section_deck(older.snippet, user: create(:user))

    described_class.call

    expect(Deck.count).to eq(2)
  end

  it "reports each deck kept" do
    _, latest = section_decks

    kept = "#{latest.word_list.name}: kept deck #{latest.id}, removed 1"
    expect(described_class.call).to eq(["#{default_user.username} · #{kept}"])
  end
end
