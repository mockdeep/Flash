# frozen_string_literal: true

class AddExampleToCards < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      change_table(:cards, bulk: true) do |t|
        t.string(:example_front)
        t.string(:example_back)
      end
    end
  end
end
