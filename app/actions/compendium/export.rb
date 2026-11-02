# frozen_string_literal: true

module Compendium
  # Writes a database's compendium tables out to a snapshot, or with `only`
  # just the tables and columns named there, returning the snapshot of what
  # it wrote.
  module Export
    def self.call(connection, snapshot, only: nil)
      layout = Compendium.layout(connection, only:)
      layout.each do |table, columns|
        path = snapshot.path(table)
        FileUtils.mkdir_p(path.dirname)
        path.open("wb") { |file| copy(connection, table, columns, file) }
      end
      snapshot.covering(layout.keys)
    end

    def self.copy(connection, table, columns, file)
      list = Compendium.quote(connection, columns)
      sql = "COPY (SELECT #{list} FROM #{table} ORDER BY id) " \
            "TO STDOUT WITH (FORMAT csv, HEADER)"

      connection.copy_data(sql) do
        while (row = connection.get_copy_data)
          file.write(row)
        end
      end
    end
  end
end
