# frozen_string_literal: true

module Snippets
  # One-off: gives every snippet its list's source, made from the list's
  # name and its snippets' shared author, link and license. A snippet's
  # title becomes its heading, less the list name and full-width colon it
  # was prefixed with. A list whose snippets disagree on those details is
  # reported and left alone. Run locally, then push.
  #
  #   Snippets::BackfillSources.call              # writes nothing
  #   Snippets::BackfillSources.call(dry_run: false)
  module BackfillSources
    extend self

    SHARED = [:author, :source_url, :license].freeze

    Report = Data.define(:sources, :headings, :skipped)

    def call(dry_run: true)
      report = Report.new(sources: [], headings: {}, skipped: [])
      ActiveRecord::Base.transaction do
        word_lists.each { |word_list| backfill(word_list, report) }
        raise ActiveRecord::Rollback if dry_run
      end
      report
    end

    private

    def word_lists
      WordList.where(id: Snippet.where(source_id: nil).select(:word_list_id))
        .order(:id)
    end

    def backfill(word_list, report)
      snippets = word_list.snippets.order(:id).to_a
      details = snippets.map { |snippet| snippet.slice(*SHARED) }.uniq
      return report.skipped << word_list.name if details.many?

      source = find_or_create_source(word_list, details.first, report)
      snippets.reject(&:source_id).each { place(it, source, report) }
    end

    def find_or_create_source(word_list, details, report)
      return word_list.source if word_list.source

      report.sources << word_list.name
      word_list.create_source!(title: word_list.name, **details)
    end

    def place(snippet, source, report)
      heading = snippet.title.delete_prefix("#{source.title}：")
      snippet.update!(source:, heading:)
      report.headings[snippet.title] = heading
    end
  end
end
