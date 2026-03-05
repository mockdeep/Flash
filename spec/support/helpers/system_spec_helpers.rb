# frozen_string_literal: true

module Helpers
  module SystemSpecHelpers
    def sign_in(user, password: "super-secure")
      visit("/")
      click_link("Log In")
      fill_in("Email", with: user.email)
      fill_in("Password", with: password)
      click_button("Log In")
    end
  end
end

RSpec.configure do |config|
  config.include(Helpers::SystemSpecHelpers, type: :system)
end
