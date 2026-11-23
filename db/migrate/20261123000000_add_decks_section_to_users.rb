# frozen_string_literal: true

class AddDecksSectionToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :decks_section, :string
  end
end
