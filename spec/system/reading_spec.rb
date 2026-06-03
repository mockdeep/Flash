# frozen_string_literal: true

RSpec.describe "study reading" do
  def start_study
    deck = create(:deck, user: default_user)
    create_list(:card, 5, deck:, reading: "liǎng")
    sign_in(default_user)
    visit(deck_study_path(deck))
  end

  def answer_a_card
    within(".study-answers-grid") { first("button").click }
  end

  it "shows the reading on the card after answering" do
    start_study
    answer_a_card

    expect(page).to have_css("#card-reading", text: "liǎng")
  end

  it "does not show the reading before answering" do
    start_study

    expect(page).to have_no_css("#card-reading")
  end
end
