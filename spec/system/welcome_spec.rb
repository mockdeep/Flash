# frozen_string_literal: true

RSpec.describe "welcome page" do
  it "has welcome text" do
    visit("/")

    expect(page).to have_text("Welcome")
  end
end
