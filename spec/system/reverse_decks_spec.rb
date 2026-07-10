# frozen_string_literal: true

RSpec.describe "reverse decks" do
  def forward_deck
    deck = create(:reading_deck, name: "Mandarin", user: default_user)
    create(:card, deck:, front: "明白", back: "understand")
    deck
  end

  def reversed_source
    deck = forward_deck
    Decks::CreateReverse.call(source: deck)
    sign_in(default_user)
    deck
  end

  it "creates a reverse deck with prompt and answer swapped" do
    sign_in(default_user)
    visit(deck_path(forward_deck))
    click_on("Create reverse deck")

    expect(page).to have_text("Mandarin (reversed)")
    expect(page).to have_text("understand")
  end

  it "hides the create button once a reverse exists" do
    visit(deck_path(reversed_source))

    expect(page).to have_text("Mandarin")
    expect(page).to have_no_button("Create reverse deck")
  end

  it "can be studied with the back as the prompt" do
    reversed_source
    visit(deck_study_path(WritingDeck.last))

    expect(page).to have_text("understand")
  end
end
