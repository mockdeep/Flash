# frozen_string_literal: true

class RemoveCanceledAtFromSubscriptions < ActiveRecord::Migration[8.1]
  def change
    safety_assured { remove_column :subscriptions, :canceled_at, :datetime }
  end
end
