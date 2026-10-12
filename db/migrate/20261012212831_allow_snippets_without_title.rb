# frozen_string_literal: true

# A snippet's title gave way to its source's title and its own heading, so
# the app stops writing it; the column goes once nothing reads it.
class AllowSnippetsWithoutTitle < ActiveRecord::Migration[8.1]
  def change
    change_column_null :snippets, :title, true
  end
end
