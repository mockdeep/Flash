# frozen_string_literal: true

class AddStudyGoalToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :study_goal, :integer

    safety_assured { User.update_all(study_goal: 50) }

    change_column_null :users, :study_goal, false
  end
end
