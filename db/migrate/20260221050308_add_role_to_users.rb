# frozen_string_literal: true

class AddRoleToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :role, :string
    User.update_all(role: "user")
    change_column_null :users, :role, false
    add_index :users, :role
  end
end
