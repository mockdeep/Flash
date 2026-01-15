# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :subscriptions do |t|
      t.references :user, foreign_key: true
      t.string :creem_subscription_id
      t.string :status
      t.datetime :current_period_start
      t.datetime :current_period_end
      t.datetime :canceled_at
      t.string :plan_name

      t.timestamps
    end
    add_index :subscriptions, :creem_subscription_id, unique: true
  end
end
