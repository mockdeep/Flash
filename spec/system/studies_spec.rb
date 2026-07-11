# frozen_string_literal: true

RSpec.describe "studying a deck" do
  def fuzzy_input
    find("input[data-fuzzy-find-target='input']")
  end

  def visit_fuzzy_deck(*card_attrs)
    deck = create(:deck, user: default_user, level: Study::FUZZY_FIND_LEVEL)
    card_attrs = [{}] if card_attrs.empty?
    card_attrs.each { |attrs| create(:basic_card, deck:, **attrs) }
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
    create_list(:basic_card, 2, deck:, back: "Paris", correct_streak: 0)
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

  context "with example sentences on a card" do
    def visit_card_with_example
      default_deck.update!(level: 2)
      create(
        :basic_card,
        deck: default_deck,
        back: "Paris",
        example_front: "Je vis à Paris.",
        example_back: "I live in Paris.",
      )
      sign_in(default_user)
      visit(deck_study_path(default_deck))
    end

    it "shows the example when toggled after answering" do
      visit_card_with_example
      click_on("Paris")
      click_on("example")

      expect(page).to have_text("Je vis à Paris.")
      expect(page).to have_text("I live in Paris.")
    end

    it "keeps the example hidden until toggled" do
      visit_card_with_example
      click_on("Paris")

      expect(page).to have_css(".study-example__toggle")
      expect(page).to have_no_text("Je vis à Paris.")
    end

    it "hides the example again with the close button" do
      visit_card_with_example
      click_on("Paris")
      click_on("example")
      click_on("Close example")

      expect(page).to have_no_text("Je vis à Paris.")
    end

    it "toggles the example with the x hotkey" do
      visit_card_with_example
      click_on("Paris")
      expect(page).to have_css(".study-example__toggle")

      find("body").send_keys("x")

      expect(page).to have_text("Je vis à Paris.")
    end

    it "does not show the example before answering" do
      visit_card_with_example

      expect(page).to have_no_text("Je vis à Paris.")
    end
  end

  it "does not render an example toggle when the card has no example" do
    default_deck.update!(level: 2)
    create(:basic_card, deck: default_deck, back: "Paris")
    answer_first_card("Paris")

    expect(page).to have_no_css(".study-example__toggle")
  end

  def answer_first_card(answer)
    sign_in(default_user)
    visit(deck_study_path(default_deck))
    click_on(answer)
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

    it "submits an answer when the user clicks a suggestion" do
      visit_fuzzy_deck(back: "Paris")
      fuzzy_input.fill_in(with: "pa")
      click_on("Paris")

      expect(page).to have_css("#correct-answer-text", text: "Paris")
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

  context "when the deck is at the reading level" do
    def visit_reading_deck
      deck = create(:deck, user: default_user, level: Study::READING_LEVEL)
      create(:basic_card, deck:, front: "两", back: "two", reading: "liǎng")
      create(:basic_card, :done, deck:, back: "three", reading: "sān")
      sign_in(default_user)
      visit(deck_study_path(deck))
    end

    it "asks the translation of the same card once the reading is picked" do
      visit_reading_deck
      expect(page).to have_text(/pick the reading/i)

      click_on("liǎng")

      expect(page).to have_css(".card-front", text: "两")
      expect(page).to have_css("#card-reading", text: "liǎng")
    end

    it "completes the card through both stages" do
      visit_reading_deck
      click_on("liǎng")
      click_on("two")

      expect(page).to have_css("#correct-answer-text", text: "two")
    end

    it "reveals the correct reading after a miss" do
      visit_reading_deck
      click_on("sān")

      expect(page).to have_css(".answer-correct", text: "liǎng")
    end
  end
end
