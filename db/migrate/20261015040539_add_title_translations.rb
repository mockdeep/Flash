# frozen_string_literal: true

class AddTitleTranslations < ActiveRecord::Migration[8.1]
  def change
    add_column :sources, :title_translation, :string
    add_column :snippets, :heading_translation, :string
  end
end
