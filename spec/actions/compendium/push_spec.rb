# frozen_string_literal: true

require "rails_helper"

RSpec.describe Compendium::Push do
  def push(dir: Pathname(Dir.mktmpdir), remote: connection, **overrides)
    admin = create(:user, :admin)
    checksum = export.checksum
    options = { checksum:, username: admin.username, **overrides }

    described_class.call(local: connection, remote:, dir:, **options)
  end

  # A second session sees only committed rows, so a migration version added
  # inside the example is invisible to it.
  # Unset options are left out, so libpq falls back to PGHOST and friends as
  # the app's own connection does.
  def with_separate_session
    config = ActiveRecord::Base.connection_db_config.configuration_hash
    options = config.slice(:database, :host, :port, :username, :password)
      .transform_keys(database: :dbname, username: :user)
    remote = PG.connect(**options.compact)
    yield(remote)
  ensure
    remote&.close
  end

  it "applies the local compendium to the remote one" do
    create(:entry)

    expect(push.changes["entries"]).to eq(added: 0, updated: 0, deleted: 0)
  end

  it "refuses while a snippet is unfinished" do
    create(:snippet_sentence, tokens: [{ "text" => "我" }])

    expect { push }.to raise_error(Compendium::Refused, /Unfinished snippets/)
  end

  it "refuses when the migrations differ" do
    connection.exec("INSERT INTO schema_migrations VALUES ('99999999999999')")

    expect { with_separate_session { |remote| push(remote:) } }
      .to raise_error(Compendium::Refused, /migrations differ/)
  end

  it "refuses without a username" do
    expect { push(username: nil) }
      .to raise_error(Compendium::Refused, /COMPENDIUM_USERNAME/)
  end

  it "refuses a username that is not an admin" do
    user = create(:user)

    expect { push(username: user.username) }
      .to raise_error(Compendium::Refused, /No admin named/)
  end

  it "refuses when the remote changed since the last pull" do
    expect { push(checksum: "stale") }
      .to raise_error(Compendium::Refused, /Production changed/)
  end
end
