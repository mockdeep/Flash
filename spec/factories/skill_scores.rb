# frozen_string_literal: true

FactoryBot.define do
  factory(:skill_score) do
    user { default_user }
    sense
    skill { "reading" }
  end
end
