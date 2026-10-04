# frozen_string_literal: true

module Helpers
  module CompendiumHelpers
    def connection = ActiveRecord::Base.connection.raw_connection

    def export(dir = Dir.mktmpdir)
      Compendium::Export.call(connection, Compendium::Snapshot.new(dir))
    end
  end
end

RSpec.configure do |config|
  config.include(
    Helpers::CompendiumHelpers,
    file_path: %r{spec/actions/compendium},
  )
end
