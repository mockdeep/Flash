# frozen_string_literal: true

module Compendium
  # Checks that a push is safe, then applies a snapshot of `local` to
  # `remote`. Raises Refused, before writing anything, when a guard fails. It
  # runs no transaction of its own: the caller commits or rolls back.
  module Push
    def self.call(local:, remote:, dir:, checksum:, username:)
      none_in_progress!
      same_migrations!(local, remote)
      owner_id = owner_id!(remote, username)
      unchanged!(remote, Snapshot.new(dir.join("production")), checksum)

      snapshot = Export.call(local, Snapshot.new(dir.join("local")))
      Apply.call(remote, snapshot, owner_id:)
    end

    # A snippet nobody has started travels as it is; one partway through
    # processing or review would carry unreviewed senses with it.
    def self.none_in_progress!
      titles = Snippet.all
        .select { |snippet| snippet.status == :in_progress }.map(&:title)
      return if titles.empty?

      raise(Refused, "Snippets in progress: #{titles.join(", ")}")
    end

    def self.same_migrations!(local, remote)
      return if migrations(local) == migrations(remote)

      raise(Refused, "Local and production migrations differ")
    end

    def self.migrations(connection)
      connection.exec("SELECT version FROM schema_migrations ORDER BY version")
        .column_values(0)
    end

    def self.owner_id!(remote, username)
      raise(Refused, "Set COMPENDIUM_USERNAME in .env.local") if username.blank?

      result = remote.exec_params(<<~SQL.squish, [username])
        SELECT id FROM users WHERE username = $1 AND role = 'admin'
      SQL
      return Integer(result.getvalue(0, 0)) if result.ntuples == 1

      raise(Refused, "No admin named #{username} in production")
    end

    def self.unchanged!(remote, snapshot, checksum)
      return if Export.call(remote, snapshot).checksum == checksum

      raise(Refused, "Production changed since the last pull; pull again")
    end
  end
end
