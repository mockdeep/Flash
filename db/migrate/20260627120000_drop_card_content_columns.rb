# frozen_string_literal: true

class DropCardContentColumns < ActiveRecord::Migration[8.1]
  def up
    safety_assured do
      change_table(:cards, bulk: true) do |t|
        t.remove :front
        t.remove :back
        t.remove :category
        t.remove :distractors
        t.remove :reading
        t.remove :example_front
        t.remove :example_back
      end
    end
  end

  def down
    change_table(:cards, bulk: true) do |t|
      t.string :front
      t.string :back
      t.string :category
      t.jsonb :distractors, default: []
      t.string :reading
      t.string :example_front
      t.string :example_back
    end
  end
end
