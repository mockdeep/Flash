# frozen_string_literal: true

class AddPairedExampleToItems < ActiveRecord::Migration[8.1]
  def change
    add_column(:items, :paired_example, :string)
  end
end
