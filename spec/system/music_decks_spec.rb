# frozen_string_literal: true

RSpec.describe "creating a music deck" do
  def visit_new_deck
    sign_in(default_user)
    visit(new_deck_path)
    expect(page).to have_text("Create New Deck")
  end

  def submit_music_form(name:, style:)
    fill_in("Deck Name", with: name)
    choose("Music (microphone required)")
    choose(style)
    attach_file(
      "Flashcards CSV File",
      "spec/fixtures/files/decks/music.csv",
      make_visible: true,
    )
    click_on("Create Deck")
  end

  def submit_text_form(name:)
    fill_in("Deck Name", with: name)
    attach_file(
      "Flashcards CSV File",
      "spec/fixtures/files/decks/basic.csv",
      make_visible: true,
    )
    click_on("Create Deck")
  end

  it "hides the Music Style fieldset when Text is selected" do
    visit_new_deck

    expect(page).to have_no_css("legend", text: "Music Style")
  end

  it "reveals the Music Style fieldset when Music is selected" do
    visit_new_deck
    choose("Music (microphone required)")

    expect(page).to have_css("legend", text: "Music Style")
  end

  it "re-hides the Music Style fieldset when switching back to Text" do
    visit_new_deck
    choose("Music (microphone required)")
    choose("Text / Flashcard")

    expect(page).to have_no_css("legend", text: "Music Style")
  end

  it "creates an ordered music deck via the form" do
    visit_new_deck
    submit_music_form(name: "Twinkle", style: "Ordered melody or scale")

    expect(MusicDeck.find_by(name: "Twinkle")&.ordered?).to be(true)
  end

  it "creates an unordered music deck via the form" do
    visit_new_deck
    submit_music_form(name: "Open Strings", style: "Unordered note pool")

    expect(MusicDeck.find_by(name: "Open Strings")&.ordered?).to be(false)
  end

  it "creates a text deck" do
    visit_new_deck
    submit_text_form(name: "Basic")

    expect(TextDeck.find_by(name: "Basic")).to be_present
  end
end
