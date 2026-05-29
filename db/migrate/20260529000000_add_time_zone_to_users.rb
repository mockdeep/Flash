# frozen_string_literal: true

class AddTimeZoneToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :time_zone, :string

    safety_assured { User.update_all(time_zone: "UTC") }

    change_column_null :users, :time_zone, false
  end
end
