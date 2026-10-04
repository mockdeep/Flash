# frozen_string_literal: true

module Compendium
  # Fills an empty database's compendium from a snapshot, giving every
  # word_list to `owner_id`. Into empty tables, applying a snapshot is
  # loading it. Ids come across as they are, so each id sequence is then
  # moved past the highest one.
  module Load
    def self.call(connection, snapshot, owner_id:)
      Apply.call(connection, snapshot, owner_id:)
      TABLES.each { |table| advance_sequence(connection, table) }
    end

    def self.advance_sequence(connection, table)
      connection.exec(<<~SQL.squish)
        SELECT setval(pg_get_serial_sequence('#{table}', 'id'),
                      COALESCE(MAX(id), 0) + 1, false)
        FROM #{table}
      SQL
    end
  end
end
