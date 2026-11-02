# frozen_string_literal: true

require "csv"

module Compendium
  # A directory holding one CSV per compendium table, with a header row and
  # rows in id order.
  class Snapshot
    attr_reader :tables

    def initialize(dir, tables: TABLES)
      @dir = Pathname(dir)
      @tables = tables
    end

    def covering(tables) = self.class.new(@dir, tables:)
    def path(table) = @dir.join("#{table}.csv")

    def checksum
      digest = Digest::SHA256.new
      tables.each { |table| digest.file(path(table)) }
      digest.hexdigest
    end

    # The columns its checksum covers, which a later push compares against
    # once migrations have added others.
    def layout
      tables.index_with { |table| CSV.parse_line(path(table).open(&:gets)) }
    end

    def empty?
      tables.all? { |table| path(table).each_line.count <= 1 }
    end
  end
end
