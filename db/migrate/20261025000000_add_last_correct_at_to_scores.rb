# frozen_string_literal: true

# When a card or sense was last answered correctly, so a streak can climb
# only once a day.
class AddLastCorrectAtToScores < ActiveRecord::Migration[8.1]
  def change
    add_column(:cards, :last_correct_at, :datetime)
    add_column(:skill_scores, :last_correct_at, :datetime)
  end
end
