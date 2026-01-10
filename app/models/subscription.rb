# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :user

  validates :polar_subscription_id, presence: true, uniqueness: true
  validates :status, presence: true

  scope :active, -> { where(status: "active") }
  scope :expired, -> { where("expires_at < ?", Time.current) }

  def active?
    status == "active" && (expires_at.nil? || expires_at > Time.current)
  end

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def cancel!
    update(status: "canceled")
  end
end
