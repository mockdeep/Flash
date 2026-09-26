# frozen_string_literal: true

# The cards a deck completed in the current batch on one day in its owner's
# time zone. "Keep Going" starts a new batch, counting again from zero.
class StudyDay < ApplicationRecord
  belongs_to :deck

  validates :deck_id, presence: true
  validates :studied_on, presence: true
  validates :completed_count, presence: true

  def self.today = find_or_create_by!(studied_on: Date.current)

  def record_completion! = increment!(:completed_count)

  def start_batch! = update!(completed_count: 0)
end
