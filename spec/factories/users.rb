# frozen_string_literal: true

FactoryBot.define do
  factory(:user) do
    role { "user" }
    sequence(:username, 100) { |n| "user_#{n}" }
    sequence(:email, 100) { |n| "user-#{n}@boon.gl" }
    password { "super-secure" }
    password_confirmation { "super-secure" }

    trait(:guest) do
      role { "guest" }
      sequence(:username, 100) { |n| "guest_#{n}" }
      sequence(:email, 100) { |n| "guest_#{n}@localhost" }
      password_digest { SecureRandom.hex }
      password { nil }
      password_confirmation { nil }
    end

    trait(:admin) do
      role { "admin" }
    end
  end
end
