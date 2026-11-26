# frozen_string_literal: true

RSpec.describe "user account" do
  def sign_up_with(
    username: "demo_user",
    email: "demo@lmkw.io",
    password: "secret",
    password_confirmation: password
  )
    visit("/")
    click_on("Sign Up")
    fill_in("Username", with: username)
    fill_in("Email", with: email)
    fill_in("Password", with: password)
    fill_in("Confirm Password", with: password_confirmation)
    click_on("Create Account")
  end

  def update_account_with(email:)
    click_on("Account")
    fill_in("Email", with: email)

    click_on("Update Account")
  end

  def delete_account
    click_on("Account")
    click_on("Delete Account")
    click_on("Permanently Delete Account")
  end

  it "allows a user to sign up for an account" do
    sign_up_with(email: "demo@example.com")

    expect(page).to have_flash(:success, "Account created")
    expect(page).to have_text("demo_user")
  end

  it "allows a user to edit their email" do
    sign_up_with(email: "demo@example.com")
    update_account_with(email: "demo2@example.com")

    expect(page).to have_text("demo_user")
  end

  it "allows a user to delete their account" do
    sign_up_with(email: "demo@example.com")

    delete_account

    expect(page).to have_flash(:success, "Account permanently deleted")
    expect(page).to have_no_text("demo_user")
  end
end
