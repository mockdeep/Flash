# frozen_string_literal: true

module Decks
  # One-off: moves every deck over a whole source onto the source's first
  # section, now that a source is studied a section at a time. A public one
  # hands its place in the catalog to its source. One whose owner already
  # has a deck for that section is deleted: progress lives on skill_scores,
  # so only its daily counts go with it. A source with no finished section
  # is reported and left alone. Run on production, then delete.
  #
  #   Decks::SplitWholeSources.call              # writes nothing
  #   Decks::SplitWholeSources.call(dry_run: false)
  module SplitWholeSources
    extend self

    Report = Data.define(:converted, :deleted, :listed, :skipped)

    def call(dry_run: true)
      report = Report.new(converted: [], deleted: [], listed: [], skipped: [])
      ActiveRecord::Base.transaction do
        decks.each { split(it, report) }
        raise ActiveRecord::Rollback if dry_run
      end
      report
    end

    private

    def decks
      lists = WordList.where(id: Source.select(:word_list_id))
      Deck.where(snippet_id: nil, word_list: lists).order(:id)
    end

    def split(deck, report)
      section = deck.source.first_section
      return report.skipped << deck.id unless section

      list(deck, report) if deck.publicly_visible?
      move(deck, section, report)
    end

    def move(deck, section, report)
      if deck.user.decks.exists?(snippet: section)
        deck.destroy!
        report.deleted << deck.id
      else
        deck.update!(snippet: section)
        report.converted << deck.id
      end
    end

    def list(deck, report)
      source = deck.source
      source.create_listing! unless source.listed?
      deck.update!(visibility: "private")
      report.listed << source.id
    end
  end
end
