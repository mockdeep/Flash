# frozen_string_literal: true

RSpec.describe "studying a deck" do
  it "shows a completion message when all cards are done" do
    create(:card, :done, deck: default_deck)

    sign_in(default_user)
    visit(deck_study_path(default_deck))

    expect(page).to have_text("Deck Complete!")
  end
end
