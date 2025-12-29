# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read("./.ruby-version").strip

gem "rails", "~> 8.1.1"

gem "bcrypt"
gem "bootsnap", require: false
gem "goldiloader"
gem "jsbundling-rails"
gem "pg"
gem "phlex-rails"
gem "propshaft"
gem "puma", "~> 7.0"
gem "strong_migrations"

group :development, :test do
  gem "bundler-audit", require: false
  gem "factory_bot_rails", require: false
  gem "rspec-rails"
end

group :development do
  gem "brakeman", require: false
  gem "guard", require: false
  gem "guard-rspec", require: false
  gem "guard-rubocop", require: false
  gem "rubocop", require: false
  gem "rubocop-capybara", require: false
  gem "rubocop-factory_bot", require: false
  gem "rubocop-i18n", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rake", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-rspec_rails", require: false
  gem "web-console"
end

group :test do
  gem "capybara", require: false
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "simplecov", require: false
  gem "webmock", require: false
end
