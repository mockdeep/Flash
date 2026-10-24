# frozen_string_literal: true

module Compendium
  # Works through the compendium a batch at a time, longest unreviewed
  # first, for `rails compendium:refine`. Each batch is entries of one
  # language with every entry sharing their headwords, briefed with the
  # cast notes of the sources its sentences come from (each built once a
  # run). Flag suggests fixes, Confirm keeps the sound ones, and those are
  # written to a file per headword for the morning. Every entry in the batch
  # is then marked reviewed, changed or not. Stops after `limit` entries, or
  # once every entry has been reviewed this run. An Llm::Error ends the run
  # with its batch unmarked, so that batch comes first next time. Yields a
  # line per batch for the caller to report, and returns how many entries
  # it reviewed.
  module Refine
    DIR = Rails.root.join("tmp/compendium_refine")
    BATCH = 20

    def self.call(limit: nil, dir: DIR, &)
      started = Time.current
      casts = {}
      reviewed = 0

      until limit && reviewed >= limit
        batch = next_batch(started)
        break if batch.empty?

        refine(batch, casts, dir, &)
        reviewed += batch.size
      end
      reviewed
    end

    def self.next_batch(started)
      due = Entry.where(reviewed_at: nil)
        .or(Entry.where(reviewed_at: ...started)).in_review_order
      first = due.first or return []
      language = first.language
      headwords = due.where(language:).limit(BATCH).pluck(:headword).uniq

      Entry.where(language:, headword: headwords).order(:headword, :id).to_a
    end

    def self.refine(batch, casts, dir)
      language = batch.first.language
      briefing = Briefing.call(batch)
      prompt = { casts: cast_notes(briefing, casts), **briefing }
      flagged = Flag.call(prompt, language:)
      kept = Confirm.call(flagged, prompt:, language:)
      lost = write(batch, kept, dir)
      batch.each { it.update!(reviewed_at: Time.current) }
      yield(summary(batch, flagged, kept, lost)) if block_given?
    end

    def self.cast_notes(briefing, casts)
      briefing[:sentences].pluck(:source_id).uniq.filter_map do |id|
        note = casts.fetch(id) { casts[id] = Cast.call(Source.find(id)) }
        { source_id: id, **note } if note
      end
    end

    # One file per headword, named for its language and first entry, so a
    # later review of the same headword replaces it. Returns the headwords
    # a suggestion named that the batch does not hold.
    def self.write(batch, kept, dir)
      groups = batch.group_by(&:headword)
      by_headword = kept.group_by { it["headword"] }

      by_headword.each do |headword, suggestions|
        entries = groups[headword]
        write_file(dir, entries, suggestions) if entries
      end
      by_headword.keys - groups.keys
    end

    def self.write_file(dir, entries, suggestions)
      first = entries.first
      FileUtils.mkdir_p(dir)
      File.write(
        dir.join("#{first.language}-#{first.id}.json"),
        JSON.pretty_generate(file(first, entries, suggestions)),
      )
    end

    def self.file(first, entries, suggestions)
      {
        language: first.language,
        headword: first.headword,
        entry_ids: entries.map(&:id),
        reviewed_at: Time.current.iso8601(6),
        suggestions: suggestions.map { it.except("headword") },
      }
    end

    def self.summary(batch, flagged, kept, lost)
      words = batch.map(&:headword).uniq
      line = "Reviewed #{batch.size} #{batch.first.language} entries " \
             "(#{words.first} … #{words.last}): " \
             "kept #{kept.size} of #{flagged.size} suggestions"
      return line if lost.empty?

      "#{line}; dropped those for #{lost.join(", ")}, not in the batch"
    end
  end
end
