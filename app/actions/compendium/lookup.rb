# frozen_string_literal: true

module Compendium
  # The compendium's entries in one language for a word, as plain text for a
  # review: each sense with its id, the lists that hold it and how many
  # snippet sentences point at it. A query is matched against headwords and
  # looked for in glosses, since a Portuguese word reads like English.
  module Lookup
    def self.call(query, language)
      entries = matching(query, language)
      return "Nothing matches #{query}" if entries.empty?

      entries.flat_map { |entry| entry_lines(entry) }.join("\n")
    end

    def self.matching(query, language)
      pattern = "%#{Sense.sanitize_sql_like(query)}%"
      glossed = Sense.where("gloss ILIKE ?", pattern).select(:entry_id)
      entries = Entry.where(language: language.code).order(:headword, :id)

      entries.where(headword: query).or(entries.where(id: glossed))
    end

    def self.entry_lines(entry)
      senses = entry.senses.order(:id).map { |sense| "  #{sense_line(sense)}" }

      ["#{entry.term} #{entry.reading} (entry ##{entry.id})", *senses]
    end

    def self.sense_line(sense)
      lists = sense.sense_memberships.map { |one| membership(one) }
      sentences = SnippetSentence.pointing_at(sense).count

      [
        "##{sense.id} #{sense.gloss}",
        sense.traditional&.then { "traditional: #{it}" },
        "lists: #{lists.join(", ").presence || "none"}",
        "snippet sentences: #{sentences}",
      ].compact.join("; ")
    end

    def self.membership(membership)
      "#{membership.word_list.name} (#{membership.category || "uncategorized"})"
    end
  end
end
