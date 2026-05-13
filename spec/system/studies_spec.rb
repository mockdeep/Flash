# frozen_string_literal: true

RSpec.describe "studying a deck" do
  def fuzzy_input
    find("input[data-fuzzy-find-target='input']")
  end

  def visit_fuzzy_deck(*card_attrs)
    deck = create(:deck, user: default_user, level: Study::FUZZY_FIND_LEVEL)
    card_attrs = [{}] if card_attrs.empty?
    card_attrs.each { |attrs| create(:card, deck:, **attrs) }
    sign_in(default_user)
    visit(deck_study_path(deck))
  end

  it "shows empty deck message when no cards to study" do
    sign_in(default_user)
    visit(deck_study_path(default_deck))

    expect(page).to have_text("No cards to study")
  end

  context "when the deck is at the fuzzy find level" do
    it "hides the multiple choice keyboard hint" do
      visit_fuzzy_deck

      expect(fuzzy_input).to be_present
      expect(page).to have_no_text("Press 1-5 to answer")
    end

    it "filters answers as the user types" do
      visit_fuzzy_deck({ back: "Paris" }, { back: "Berlin" })
      fuzzy_input.fill_in(with: "pa")

      expect(page).to have_button("Paris")
      expect(page).to have_no_button("Berlin")
    end

    it "submits the typed answer when the user presses Enter" do
      visit_fuzzy_deck(back: "Paris")
      fuzzy_input.fill_in(with: "pa")
      fuzzy_input.send_keys(:enter)

      expect(page).to have_css("#correct-answer-text", text: "Paris")
    end

    it "shows a 'no matches' message when nothing matches the input" do
      visit_fuzzy_deck(back: "Paris")
      fuzzy_input.fill_in(with: "xyz")

      expect(page).to have_text("No matches")
    end
  end
end
