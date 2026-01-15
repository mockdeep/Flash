# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :user

  validates :creem_subscription_id, presence: true, uniqueness: true
  validates :status, presence: true

  def active?
    status == "active"
  end

  def canceled?
    status == "canceled"
  end
end
