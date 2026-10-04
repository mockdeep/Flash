# frozen_string_literal: true

module Compendium
  module Pull
    # Whether the local compendium holds work a pull would throw away: it
    # differs from what the last pull or push left. An empty compendium has
    # nothing to lose.
    def self.unpushed?(local, dir, checksum)
      snapshot = Export.call(local, Snapshot.new(dir.join("local")))

      !snapshot.empty? && snapshot.checksum != checksum
    end
  end
end
