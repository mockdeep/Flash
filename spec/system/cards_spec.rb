# frozen_string_literal: true

RSpec.describe "editing a card" do
  def setup_card_study
    card = create_card
    sign_in(default_user)
    visit(deck_study_path(default_deck))
    click_on("Correct answer")
    card
  end

  def edit_card(field, value)
    click_on("Edit card")
    fill_in(field, with: value)
    click_on("Save")
  end

  def create_card
    default_deck.update!(level: 2)
    create(
      :card,
      deck: default_deck,
      front: "Original question",
      back: "Correct answer",
      distractors: ["Wrong 1", "Wrong 2", "Wrong 3", "Wrong 4"],
    )
  end

  it "shows the edit card button on the feedback screen" do
    setup_card_study

    expect(page).to have_button("Edit card")
  end

  it "opens the edit modal when clicking the edit button" do
    setup_card_study
    click_on("Edit card")

    expect(page).to have_css("dialog[open]")
  end

  it "pre-fills the form with the card's current values" do
    setup_card_study
    click_on("Edit card")

    expect(page).to have_field("Front", with: "Original question")
    expect(page).to have_field("Back", with: "Correct answer")
  end

  it "saves changes and updates the card" do
    card = setup_card_study
    edit_card("Front", "UpdatedQuestion")
    expect(page).to have_text("UpdatedQuestion")

    expect(card.reload.front).to eq("UpdatedQuestion")
  end

  it "closes the modal after saving" do
    setup_card_study
    click_on("Edit card")
    fill_in("Front", with: "UpdatedQuestion")
    click_on("Save")

    expect(page).to have_no_css("dialog[open]")
  end

  it "closes the modal when clicking the close button" do
    setup_card_study
    click_on("Edit card")
    click_on("✕")

    expect(page).to have_no_css("dialog[open]")
  end

  it "keeps the modal open on validation error" do
    setup_card_study
    click_on("Edit card")
    fill_in("Front", with: "")
    click_on("Save")

    expect(page).to have_css("dialog[open] .error-explanation")
  end

  context "with a card copied from another user's catalog deck" do
    def setup_catalog_copy_study
      source = build_source_card
      card = create_card
      card.update!(source_card: source)
      sign_in(default_user)
      visit(deck_study_path(default_deck))
      click_on("Correct answer")
      [source, card]
    end

    def build_source_card
      catalog = create(:deck, user: create(:user), visibility: "public")
      create(:card, deck: catalog)
    end

    it "shows the suggest-to-catalog checkbox in the edit modal" do
      setup_catalog_copy_study
      click_on("Edit card")

      expect(page).to have_field("Suggest this edit to the catalog deck")
    end

    it "creates a suggestion when the checkbox is checked and saved" do
      source, _card = setup_catalog_copy_study
      check_suggest_and_save("Better question")

      expect(source.suggestions.pending.count).to eq(1)
    end

    it "does not create a suggestion when the checkbox is left unchecked" do
      source, _card = setup_catalog_copy_study
      edit_card("Front", "Better question")

      expect(source.suggestions.count).to eq(0)
    end

    def check_suggest_and_save(new_front)
      click_on("Edit card")
      fill_in("Front", with: new_front)
      check("Suggest this edit to the catalog deck")
      click_on("Save")
      expect(page).to have_text(new_front)
    end
  end

  context "with a card that is not a catalog copy" do
    it "does not show the suggest-to-catalog checkbox" do
      setup_card_study
      click_on("Edit card")

      expect(page).to have_no_field("Suggest this edit to the catalog deck")
    end
  end

  describe "deleting a card" do
    it "removes the card after confirming" do
      card = setup_card_study
      click_on("Edit card")
      accept_confirm { click_on("Delete") }
      expect(page).to have_no_css("dialog[open]")

      expect { card.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "keeps the card when the confirm is dismissed" do
      card = setup_card_study
      click_on("Edit card")
      dismiss_confirm { click_on("Delete") }

      expect { card.reload }.not_to raise_error
    end
  end
end
