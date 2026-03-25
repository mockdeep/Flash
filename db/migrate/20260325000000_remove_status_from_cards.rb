# frozen_string_literal: true

class RemoveStatusFromCards < ActiveRecord::Migration[8.1]
  def change
    safety_assured { remove_column :cards, :status, :string }
  end
end
