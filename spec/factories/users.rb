# frozen_string_literal: true

FactoryBot.define do
  factory(:user) do
    sequence(:username, 100) { |n| "user_#{n}" }
    sequence(:email, 100) { |n| "user-#{n}@boon.gl" }
    password { "super-secure" }
    password_confirmation { "super-secure" }
  end
end
