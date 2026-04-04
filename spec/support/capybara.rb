# frozen_string_literal: true

require "capybara/rails"

require_relative "capybara/rack_test"

Capybara.enable_aria_label = true
Capybara.save_path = ENV.fetch("CIRCLE_ARTIFACTS", Capybara.save_path)
Capybara.server = :puma, { Silent: true }

driver = ENV.fetch("DRIVER", :firefox).to_sym

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by(:selenium, using: driver)
  end
end
