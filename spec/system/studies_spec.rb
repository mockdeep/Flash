# frozen_string_literal: true

RSpec.describe "studying a deck" do
  it "shows empty deck message when no cards to study" do
    sign_in(default_user)
    visit(deck_study_path(default_deck))

    expect(page).to have_text("No cards to study")
  end
end
