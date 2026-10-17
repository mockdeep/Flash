# frozen_string_literal: true

module Compendium
  # Edits to the compendium itself, made locally and carried to production
  # by `compendium:push`; called from a Claude Code session through
  # `bin/rails runner`. Local copies hold no learner data, so the dry-run
  # push is where an edit's cost to learners shows.
  module Edit
    class Refused < StandardError; end

    # A sense under a headword, made unless the entry for that reading and
    # article already holds the gloss.
    def self.add(language:, headword:, reading:, gloss:, article: nil)
      Snippets::Record.entry_for(language, headword, reading, article:).senses
        .find_or_create_by!(gloss:)
    end

    # A reading or article belongs to the entry, so a new one moves the
    # sense to the entry that has it; an entry left without senses goes.
    def self.revise(sense, gloss: nil, reading: nil, article: nil)
      old_entry = sense.entry
      moves = { reading:, article: }.compact
      entry = moves.any? ? moved(old_entry, **moves) : old_entry
      sense.update!(entry:, gloss: gloss || sense.gloss)
      old_entry.destroy! if old_entry.senses.none?
      sense
    end

    def self.moved(entry, reading: entry.reading, article: entry.article)
      Snippets::Record
        .entry_for(entry.language, entry.headword, reading, article:)
    end

    # Deletes a sense nothing uses: no token, no list and no learner.
    def self.remove(sense)
      users = users_of(sense)
      if users.any?
        raise(Refused, "Sense #{sense.id} is used by #{users.join(", ")}")
      end

      entry = sense.entry
      sense.destroy!
      entry.destroy! if entry.senses.none?
    end

    # Puts a sense into a list after the senses it holds; one already there
    # stays where it is.
    def self.attach(sense, word_list, category: nil)
      memberships = word_list.sense_memberships
      position = (memberships.maximum(:position) || 0) + 1

      memberships.create_with(position:, category:).find_or_create_by!(sense:)
    end

    def self.detach(sense, word_list)
      word_list.sense_memberships.find_by!(sense:).destroy!
    end

    def self.users_of(sense)
      {
        "snippet tokens" => SnippetSentence.pointing_at(sense),
        "word lists" => sense.sense_memberships,
        "learner progress" => sense.skill_scores,
        "distractor history" => sense.sense_distractors,
      }.select { |_, records| records.exists? }.keys
    end
  end
end
