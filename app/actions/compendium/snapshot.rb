# frozen_string_literal: true

module Compendium
  # A directory holding one CSV per compendium table, with a header row and
  # rows in id order.
  class Snapshot
    def initialize(dir)
      @dir = Pathname(dir)
    end

    def path(table) = @dir.join("#{table}.csv")

    def checksum
      digest = Digest::SHA256.new
      TABLES.each { |table| digest.file(path(table)) }
      digest.hexdigest
    end

    def empty?
      TABLES.all? { |table| path(table).each_line.count <= 1 }
    end
  end
end
