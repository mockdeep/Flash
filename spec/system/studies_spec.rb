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

  def reach_milestone
    deck = create(:deck, user: default_user, study_goal: 1, level: 1)
    create_list(:card, 2, deck:, back: "Paris", correct_streak: 0)
    sign_in(default_user)
    visit(deck_study_path(deck))
    click_on("Paris", match: :first)
    click_on("Next Card")
  end

  it "advances past the milestone when the space hotkey is pressed" do
    reach_milestone
    expect(page).to have_text("You've completed 1 cards")

    find("body").send_keys(:space)

    expect(page).to have_no_text("You've completed 1 cards")
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
