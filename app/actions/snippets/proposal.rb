# frozen_string_literal: true

module Snippets
  # A proposer's decision for one occurrence: an existing sense, a new one,
  # or a complaint that the token is missegmented. Only a new sense goes
  # before the judge; selection among existing senses measured accurate
  # enough to stand alone (docs/compendium.md).
  Proposal =
    Struct.new(
      :occurrence, :decision, :sense_id, :reading, :gloss, :note, :article
    ) do
      def self.from(occurrence, row)
        new(occurrence, *row.values_at(*members.drop(1).map(&:to_s)))
      end

      def new_sense? = decision == "new"

      delegate :headword, :language, to: :occurrence

      def problem
        if decision == "existing" && !listed_sense?
          "sense_id #{sense_id} is not one of this word's listed senses"
        elsif new_sense?
          new_sense_problem
        end
      end

      # A language without readings files its senses under none, whatever
      # the proposer said.
      def sense_reading
        reading.presence if language.readings
      end

      # Only a language with articles files a noun under one.
      def sense_article
        article.presence if language.articles.any?
      end

      # What the judge is shown beside the occurrence.
      def proposed
        { headword:, reading: sense_reading, article: sense_article, gloss: }
          .compact
      end

      private

      def listed_sense? = occurrence.senses.map(&:id).include?(sense_id)

      def new_sense_problem
        missing = [
          ("a reading" if language.readings && reading.blank?),
          ("a gloss" if gloss.blank?),
        ].compact
        return "a new sense needs #{missing.join(" and ")}" if missing.any?

        article_problem
      end

      def article_problem
        articles = language.articles
        return if sense_article.nil? || articles.include?(sense_article)

        "the article must be one of #{articles.join(", ")}"
      end
    end
end
