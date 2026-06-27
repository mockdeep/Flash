# frozen_string_literal: true

RSpec.describe "importing a deck with example sentences" do
  def upload(fixture)
    sign_in(default_user)
    visit(new_deck_path)
    fill_in("Deck Name", with: "Spanish basics")
    attach_file(
      "Flashcards CSV File",
      "spec/fixtures/files/decks/#{fixture}",
      make_visible: true,
    )
    click_on("Create Deck")
  end

  it "persists example_front and example_back on imported cards" do
    upload("with_examples.csv")
    attrs = { example_front: "Hola mundo", example_back: "Hello world" }

    expect(card_for("hola")).to have_attributes(attrs)
  end

  def card_for(front)
    default_user.decks.last.cards.joins(:item).find_by(items: { text: front })
  end

  it "leaves example fields nil when both row values are blank" do
    upload("with_examples.csv")

    expect(card_for("gracias"))
      .to have_attributes(example_front: nil, example_back: nil)
  end

  it "rejects uploads with only one of the example columns" do
    upload("example_only_front.csv")

    expect(page).to have_text(
      "must include both 'example_front' and 'example_back' columns or neither",
    )
  end
end
