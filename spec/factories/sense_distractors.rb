# frozen_string_literal: true

FactoryBot.define do
  factory(:sense_distractor) do
    user { default_user }
    sense
    distractor_sense { association(:sense) }
    miss_count { 1 }
    last_missed_at { Time.current }
  end
end
