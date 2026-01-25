# frozen_string_literal: true

FactoryBot.define do
  factory(:subscription) do
    user { default_user }
    sequence(:creem_subscription_id, 100) { |n| "sub_test_#{n}" }
    status { "active" }
    plan_name { "Flash Supporter" }
    current_period_start { 1.month.ago }
    current_period_end { 1.month.from_now }

    trait(:canceled) do
      status { "canceled" }
    end

    trait(:past_due) do
      status { "past_due" }
    end
  end
end
