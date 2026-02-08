# frozen_string_literal: true

class AddUsernameToUsers < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      add_column :users, :username, :string

      User.reset_column_information
      User.find_each do |user|
        base = user.email.split("@").first
        candidate = base
        counter = 2
        while User.where(username: candidate).where.not(id: user.id).exists?
          candidate = "#{base}_#{counter}"
          counter += 1
        end
        user.update!(username: candidate)
      end

      change_column_null :users, :username, false
      add_index :users, :username, unique: true
    end
  end
end
