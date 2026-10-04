# frozen_string_literal: true

module Compendium
  # Copies one table's snapshot into a temporary table shaped like it, where
  # Load and Apply can read it with plain SQL. HEADER MATCH makes Postgres
  # refuse a snapshot whose columns differ from the table's.
  module Staging
    CHUNK = 64.kilobytes

    def self.create(connection, snapshot, table)
      name = name(table)
      connection.exec(<<~SQL.squish)
        CREATE TEMP TABLE #{name} AS
        SELECT #{Compendium.column_list(connection, table)} FROM #{table}
        WITH NO DATA
      SQL
      fill(connection, name, snapshot.path(table))
      name
    end

    def self.drop(connection, table)
      connection.exec("DROP TABLE #{name(table)}")
    end

    def self.name(table) = "compendium_staging_#{table}"

    def self.fill(connection, name, path)
      sql = "COPY #{name} FROM STDIN WITH (FORMAT csv, HEADER MATCH)"

      connection.copy_data(sql) do
        path.open("rb") do |file|
          while (chunk = file.read(CHUNK))
            connection.put_copy_data(chunk)
          end
        end
      end
    end
  end
end
