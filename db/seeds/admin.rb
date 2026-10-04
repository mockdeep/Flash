# frozen_string_literal: true

module Seeds
  # The local admin: owns the seeded music decks and every word_list a
  # compendium pull brings down. Its password is public, so it is never made
  # outside development and test.
  module Admin
    USERNAME = "admin"

    class PublicLoginError < StandardError; end

    def self.call
      unless Rails.env.local?
        raise(PublicLoginError, "Not seeding a public admin in #{Rails.env}")
      end

      User.where(username: USERNAME).first_or_create! do |user|
        user.email = "admin@example.com"
        user.password = "password"
        user.role = "admin"
        user.time_zone = "UTC"
      end
    end
  end
end
