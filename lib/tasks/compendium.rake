# frozen_string_literal: true

require "open3"

# Moves the compendium between this machine and production through a
# snapshot in tmp/compendium (docs/compendium.md, Compendium sync). The
# checksum of the compendium local last matched production on is kept in
# ar_internal_metadata.
module CompendiumTasks
  CHECKSUM = "compendium_checksum"
  DIR = Rails.root.join("tmp/compendium")
  UNPUSHED = "Local compendium has unpushed changes; push them, " \
             "or pull with FORCE=true to discard them"

  extend self

  def pull
    abort(UNPUSHED) if ENV["FORCE"] != "true" && unpushed?

    snapshot = with_production { |remote| export_production(remote) }
    reset
    ActiveRecord::Base.transaction do
      Compendium::Load.call(local, snapshot, owner_id: Seeds::Admin.call.id)
    end
    metadata[CHECKSUM] = snapshot.checksum
    puts("Pulled; the word lists belong to #{Seeds::Admin::USERNAME}")
  end

  def push
    with_production do |remote|
      remote.exec("BEGIN")
      puts(Compendium::Push.call(local:, remote:, dir: DIR, **credentials))
      ENV["DRY_RUN"] == "false" ? commit(remote) : roll_back(remote)
    end
  rescue Compendium::Refused => e
    abort("Push refused: #{e.message}")
  end

  def unpushed? = Compendium::Pull.unpushed?(local, DIR, metadata[CHECKSUM])

  def export_production(remote)
    snapshot = Compendium::Snapshot.new(DIR.join("production"))
    Compendium::Export.call(remote, snapshot)
  end

  # Postgres will not drop a database anyone is connected to, and the
  # unpushed check holds a connection.
  def reset
    ActiveRecord::Base.connection_pool.disconnect!
    Rake::Task["db:reset"].invoke
    require(Rails.root.join("db/seeds/admin").to_s)
  end

  def credentials
    username = ENV.fetch("COMPENDIUM_USERNAME", nil)

    { checksum: metadata[CHECKSUM], username: }
  end

  def commit(remote)
    remote.exec("COMMIT")
    metadata[CHECKSUM] = Compendium::Snapshot.new(DIR.join("local")).checksum
    puts("Pushed")
  end

  def roll_back(remote)
    remote.exec("ROLLBACK")
    puts("Dry run, rolled back. Push with DRY_RUN=false to commit")
  end

  # Fetched fresh every run, since Heroku rotates it, and never written down.
  # Closing the connection rolls back anything left uncommitted.
  def with_production
    url, status = Open3.capture2(
      "heroku", "config:get", "DATABASE_URL", "--app", "flash"
    )
    abort("Could not fetch production's DATABASE_URL") unless status.success?

    remote = PG.connect(url.strip)
    yield(remote)
  ensure
    remote&.close
  end

  def local = ActiveRecord::Base.connection.raw_connection
  def metadata = ActiveRecord::Base.connection_pool.internal_metadata
end

namespace(:compendium) do
  desc(
    "Reset the local database to production's compendium " \
    "(FORCE=true discards unpushed work)",
  )
  task(pull: :environment) { CompendiumTasks.pull }

  desc(
    "Mirror the local compendium to production " \
    "(a dry run unless DRY_RUN=false)",
  )
  task(push: :environment) { CompendiumTasks.push }
end
