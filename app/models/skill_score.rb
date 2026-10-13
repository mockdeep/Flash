# frozen_string_literal: true

# One user's progress on one sense in one skill, independent of any deck.
class SkillScore < ApplicationRecord
  include StudyCounters

  SKILLS = ["reading", "writing"].freeze

  belongs_to :user
  belongs_to :sense

  validates :skill, inclusion: { in: SKILLS }
  validates :sense_id, uniqueness: { scope: [:user_id, :skill] }

  # How the word stands at a deck's level, as the Read tab marks it; nil
  # while it is part way there.
  def state(level)
    if view_count.zero?
      "new"
    elsif correct_streak.zero?
      "missed"
    elsif correct_streak >= level
      "done"
    end
  end
end
