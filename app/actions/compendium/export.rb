# frozen_string_literal: true

module Compendium
  # Writes a database's compendium tables out to a snapshot.
  module Export
    def self.call(connection, snapshot)
      TABLES.each do |table|
        path = snapshot.path(table)
        FileUtils.mkdir_p(path.dirname)
        path.open("wb") { |file| copy(connection, table, file) }
      end
      snapshot
    end

    def self.copy(connection, table, file)
      columns = Compendium.column_list(connection, table)
      sql = "COPY (SELECT #{columns} FROM #{table} ORDER BY id) " \
            "TO STDOUT WITH (FORMAT csv, HEADER)"

      connection.copy_data(sql) do
        while (row = connection.get_copy_data)
          file.write(row)
        end
      end
    end
  end
end
