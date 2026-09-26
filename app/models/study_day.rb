# frozen_string_literal: true

# The cards a deck completed in the current batch on one day in its owner's
# time zone. "Keep Going" starts a new batch, counting again from zero. A
# deck with a level target saves the day's goal here when the row is made,
# and again whenever it is recalculated.
class StudyDay < ApplicationRecord
  belongs_to :deck

  validates :deck_id, presence: true
  validates :studied_on, presence: true
  validates :completed_count, presence: true

  def self.today
    find_or_create_by!(studied_on: Date.current) do |study_day|
      study_day.goal = study_day.deck.target_goal
    end
  end

  def study_goal = goal || deck.study_goal

  def record_completion! = increment!(:completed_count)

  def start_batch! = update!(completed_count: 0)

  def recalculate! = update!(goal: deck.target_goal, completed_count: 0)
end
