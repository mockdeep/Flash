# frozen_string_literal: true

module Snippets
  # A proposer's decision for one occurrence: an existing sense, a new one,
  # or a complaint that the token is missegmented. Only a new sense goes
  # before the judge; selection among existing senses measured accurate
  # enough to stand alone (docs/compendium.md).
  Proposal =
    Struct.new(:occurrence, :decision, :sense_id, :reading, :gloss, :note) do
      def self.from(occurrence, row)
        new(occurrence, *row.values_at(*members.drop(1).map(&:to_s)))
      end

      def new_sense? = decision == "new"

      delegate :headword, to: :occurrence

      def problem
        if decision == "existing" && !listed_sense?
          "sense_id #{sense_id} is not one of this word's listed senses"
        elsif new_sense?
          new_sense_problem
        end
      end

      # What the judge is shown beside the occurrence.
      def proposed = { headword:, reading:, gloss: }

      private

      def listed_sense? = occurrence.senses.map(&:id).include?(sense_id)

      def new_sense_problem
        return if reading.present? && gloss.present?

        "a new sense needs both a reading and a gloss"
      end
    end
end
