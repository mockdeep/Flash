# frozen_string_literal: true

RSpec.describe "user sessions" do
  let(:password) { "secret" }
  let(:user) { create(:user, password:, password_confirmation: password) }

  def sign_in_with(email:, password:)
    visit("/")

    click_on("Log In")

    expect(page).to have_text("Welcome Back")

    fill_in("Email", with: email)
    fill_in("Password", with: password)

    click_on("Log In")
  end

  it "allows a user to log into their account" do
    sign_in_with(email: user.email, password:)

    expect(page).to have_text(user.username)
    expect(page).to have_link("Account")
    expect(page).to have_no_link("Log In")
  end

  it "allows a user to log out" do
    sign_in_with(email: user.email, password:)

    click_on("Log Out")

    expect(page).to have_link("Log In")
    expect(page).to have_no_text(user.username)
  end
end
