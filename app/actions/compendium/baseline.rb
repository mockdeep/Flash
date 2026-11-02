# frozen_string_literal: true

module Compendium
  # What the last pull or push left: the snapshot's checksum and the columns
  # it covers, by table. No `columns` means every current one.
  Baseline = Data.define(:checksum, :columns)

  class Baseline
    def initialize(checksum:, columns: nil) = super
  end
end
