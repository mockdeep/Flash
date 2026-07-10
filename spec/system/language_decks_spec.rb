# frozen_string_literal: true

RSpec.describe "creating a language deck" do
  def visit_new_deck
    sign_in(default_user)
    visit(new_deck_path)
    expect(page).to have_text("Create New Deck")
  end

  def submit_language_form(name:, language:)
    fill_in("Deck Name", with: name)
    choose("Language")
    select(language, from: "Language")
    attach_file(
      "Flashcards CSV File",
      "spec/fixtures/files/decks/basic.csv",
      make_visible: true,
    )
    click_on("Create Deck")
  end

  it "hides the language select when Basic is selected" do
    visit_new_deck

    expect(page).to have_no_select("Language")
  end

  it "reveals the language select when Language is selected" do
    visit_new_deck
    choose("Language")

    expect(page).to have_select("Language")
  end

  it "re-hides the language select when switching back to Basic" do
    visit_new_deck
    choose("Language")
    choose("Basic")

    expect(page).to have_no_select("Language")
  end

  it "creates a deck with the selected language via the form" do
    visit_new_deck
    submit_language_form(name: "Vocab", language: "Spanish")

    expect(page).to have_text("Deck created successfully")
    expect(DataSet.find_by(name: "Vocab").language).to eq("es")
  end

  it "creates a deck with a language outside the common group" do
    visit_new_deck
    submit_language_form(name: "tlhIngan Hol", language: "Klingon")

    expect(page).to have_text("Deck created successfully")
    expect(DataSet.find_by(name: "tlhIngan Hol").language).to eq("tlh")
  end
end
