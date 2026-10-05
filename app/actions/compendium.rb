# frozen_string_literal: true

# The local tools for the compendium: looking it up and editing it
# (Lookup, Edit), and syncing it between a local database and production
# through a snapshot, one CSV per table (docs/compendium.md, Compendium
# sync). The sync operations take a raw PG::Connection, so the same code
# runs against either side.
module Compendium
  # Parents before children: rows are added in this order and removed in
  # reverse, so no foreign key is ever left dangling.
  TABLES = [
    "entries",
    "senses",
    "sense_examples",
    "word_lists",
    "sense_memberships",
    "snippets",
    "snippet_sentences",
  ].freeze
  # Owners never travel: local lists belong to the seed user, production's
  # to whoever made them.
  OWNER_COLUMN = { "word_lists" => "user_id" }.freeze
  COLUMNS_SQL = <<~SQL.squish
    SELECT column_name FROM information_schema.columns
    WHERE table_schema = current_schema() AND table_name = $1
  SQL

  class Refused < StandardError; end

  # Sorted by name rather than position, so a database built from schema.rb
  # and one built by migrations write their columns in the same order.
  def self.columns(connection, table)
    names = connection.exec_params(COLUMNS_SQL, [table]).column_values(0)

    (names - [OWNER_COLUMN[table]]).sort
  end

  def self.quote(connection, columns, prefix: "")
    columns.map { |name| prefix + connection.quote_ident(name) }.join(", ")
  end

  def self.column_list(connection, table, prefix: "")
    quote(connection, columns(connection, table), prefix:)
  end
end
