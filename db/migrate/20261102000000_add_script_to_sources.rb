# frozen_string_literal: true

class AddScriptToSources < ActiveRecord::Migration[8.1]
  def change
    add_column :sources, :script, :string, null: false, default: "simplified"
  end
end
