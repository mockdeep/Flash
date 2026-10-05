# frozen_string_literal: true

module Compendium
  # The compendium's entries for a word, as plain text for a review: each
  # sense with its id, the lists that hold it and how many snippet sentences
  # point at it. A query with Chinese characters is a headword; anything else
  # is looked for in the glosses.
  module Lookup
    def self.call(query)
      entries = matching(query)
      return "Nothing matches #{query}" if entries.empty?

      entries.flat_map { |entry| entry_lines(entry) }.join("\n")
    end

    def self.matching(query)
      entries = Entry.where(language: Snippet::LANGUAGE).order(:headword, :id)
      if query.match?(SnippetSentence::HAN)
        return entries.where(headword: query)
      end

      pattern = "%#{Sense.sanitize_sql_like(query)}%"
      entries.where(id: Sense.where("gloss ILIKE ?", pattern).select(:entry_id))
    end

    def self.entry_lines(entry)
      senses = entry.senses.order(:id).map { |sense| "  #{sense_line(sense)}" }

      ["#{entry.headword} #{entry.reading} (entry ##{entry.id})", *senses]
    end

    def self.sense_line(sense)
      lists = sense.sense_memberships.map { |one| membership(one) }
      sentences = SnippetSentence.pointing_at(sense).count

      [
        "##{sense.id} #{sense.gloss}",
        "lists: #{lists.join(", ").presence || "none"}",
        "snippet sentences: #{sentences}",
      ].join("; ")
    end

    def self.membership(membership)
      "#{membership.word_list.name} (#{membership.category || "uncategorized"})"
    end
  end
end
