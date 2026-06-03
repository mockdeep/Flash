# frozen_string_literal: true

class AddReadingToCards < ActiveRecord::Migration[8.1]
  def change
    add_column :cards, :reading, :string
  end
end
