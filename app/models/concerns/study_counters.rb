# frozen_string_literal: true

# The streak arithmetic every scored row shares: flat cards, and for
# language decks the per-sense skill scores.
module StudyCounters
  extend ActiveSupport::Concern

  included do
    validates :correct_count, presence: true
    validates :correct_streak, presence: true
    validates :view_count, presence: true
  end

  def record_correct!
    self.view_count += 1
    self.correct_count += 1
    self.correct_streak += 1
    save!
  end

  def record_miss!
    self.view_count += 1
    self.correct_streak = 0
    save!
  end

  def record_view!
    self.view_count += 1
    save!
  end
end
