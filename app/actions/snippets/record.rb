# frozen_string_literal: true

module Snippets
  # Turns a settled or accepted proposal into what its token records. The
  # decision is what the model said; the outcome is what happened, in the
  # past tense. A new sense enters the compendium here. "missegmented" is
  # never saved: Resolve sends the sentence back to the segmenter, or
  # leaves the token unresolved.
  module Record
    def self.call(proposal)
      case proposal.decision
      when "missegmented"
        { "outcome" => "missegmented", "note" => proposal.note }
      when "existing"
        { "outcome" => "matched", "sense_id" => proposal.sense_id }
      else record_new(proposal)
      end
    end

    # A sense the judge passed as new can still be one the entry already
    # holds under that gloss, in which case the token matched it after all,
    # whatever its traditional form: Finish settles spelling.
    def self.record_new(proposal)
      entry = entry_for(
        proposal.language.code,
        proposal.headword,
        proposal.sense_reading,
        article: proposal.sense_article,
      )
      sense = entry.senses.create_with(traditional: proposal.traditional)
        .find_or_create_by!(gloss: proposal.gloss)
      outcome = sense.previously_new_record? ? "created" : "matched"

      { "outcome" => outcome, "sense_id" => sense.id }
    end

    # Seed readings follow the HSK syllabus's spelling (curly apostrophes,
    # hyphenated idioms), so an entry matches on the letters alone rather
    # than gaining a twin that differs only in punctuation. Case counts: a
    # capitalized reading is a name, never the common word read the same.
    def self.entry_for(language, headword, reading, article: nil)
      twins = Entry.where(language:, headword:, article:)
      twins.find { |entry| letters(entry.reading) == letters(reading) } ||
        twins.create!(reading:)
    end

    def self.letters(reading) = reading.to_s.gsub(/[^[:alpha:]]/, "")
  end
end
