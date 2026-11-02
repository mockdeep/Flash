# frozen_string_literal: true

require "rails_helper"

RSpec.describe Compendium::Push do
  def push(remote: connection, checksum: export.checksum, columns: nil, **rest)
    admin = create(:user, :admin)
    baseline = Compendium::Baseline.new(checksum:, columns:)
    options = { baseline:, username: admin.username, **rest }
    dir = Pathname(Dir.mktmpdir)

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

  it "refuses while a snippet is in progress" do
    create(:snippet_sentence, tokens: [{ "text" => "我" }])

    expect { push }.to raise_error(Compendium::Refused, /Snippets in progress/)
  end

  it "refuses while a source's front matter is in progress" do
    source = create(:source, title: "春节")
    create(:front_matter, source:, tokens: [{ "text" => "春节" }])

    expect { push }.to raise_error(Compendium::Refused, /in progress: 春节/)
  end

  it "carries a snippet nobody has started" do
    create(:snippet_sentence, tokens: [])

    expect(push.changes["snippets"]).to eq(added: 0, updated: 0, deleted: 0)
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

  context "when the checksum covers only some columns" do
    def covered
      columns = Compendium.columns(connection, "sources") - ["script"]

      { "sources" => columns }
    end

    def covered_checksum
      snapshot = Compendium::Snapshot.new(Dir.mktmpdir)

      Compendium::Export.call(connection, snapshot, only: covered).checksum
    end

    it "lets a push through past a column added since" do
      checksum = covered_checksum

      expect(push(checksum:, columns: covered).changes["sources"])
        .to eq(added: 0, updated: 0, deleted: 0)
    end

    it "still refuses when a covered column changed" do
      source = create(:source)
      checksum = covered_checksum
      source.update!(title: "Changed")

      expect { push(checksum:, columns: covered) }
        .to raise_error(Compendium::Refused, /Production changed/)
    end
  end
end
