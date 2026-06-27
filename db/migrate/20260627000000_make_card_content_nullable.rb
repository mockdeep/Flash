# frozen_string_literal: true

class MakeCardContentNullable < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      change_table(:cards, bulk: true) do |t|
        t.change_null(:front, true)
        t.change_null(:back, true)
        t.change_null(:category, true)
        t.change_null(:distractors, true)
      end
    end
  end
end
