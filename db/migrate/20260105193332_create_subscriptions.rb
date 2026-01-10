# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :subscriptions do |t|
      t.references :user, foreign_key: true
      t.string :polar_subscription_id
      t.string :status
      t.datetime :expires_at

      t.timestamps
    end
    add_index :subscriptions, :polar_subscription_id, unique: true
  end
end
