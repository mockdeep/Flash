# frozen_string_literal: true

module Snippets
  # A snippet as a review sees it, as plain text: a summary line, the words
  # left unresolved and the senses created, then every sentence token by
  # token, with the sentence ids, token indexes and sense ids that
  # Snippets::Review takes.
  module Report
    def self.call(snippet)
      tokens = snippet.sentences.flat_map(&:tokens)

      [
        heading(snippet, tokens),
        *section("Unresolved", unresolved(snippet)),
        *section("Created", created(tokens)),
        *snippet.sentences.flat_map { |sentence| sentence_lines(sentence) },
      ].join("\n")
    end

    # Senses no list holds and no token points at, such as those a sentence
    # created before it was segmented again: candidates for Review.remove.
    def self.unused
      senses = Sense.where.missing(:sense_memberships)
        .where.not(id: SnippetSentence.sense_ids).order(:id)

      section("Unused senses", senses.map { |sense| "  #{describe(sense)}" })
        .join("\n")
    end

    def self.heading(snippet, tokens)
      counts = tokens.filter_map { |token| token["outcome"] }.tally
      tally = counts.map { |outcome, count| "#{count} #{outcome}" }
      name = "Snippet #{snippet.id} \"#{snippet.title}\""

      "#{name} (list #{snippet.word_list.name}): " +
        [snippet.status, *tally].join(", ")
    end

    def self.section(title, lines)
      lines.empty? ? [] : ["#{title}:", *lines]
    end

    def self.unresolved(snippet)
      snippet.sentences.flat_map do |sentence|
        sentence.tokens.each_with_index.filter_map do |token, index|
          next unless token["outcome"] == "unresolved"

          "  sentence #{sentence.id} token #{index} #{token["text"]}: " \
            "#{token["note"]}"
        end
      end
    end

    def self.created(tokens)
      created = tokens.select { |token| token["outcome"] == "created" }
      senses = Sense.where(id: created.pluck("sense_id")).order(:id)

      senses.map { |sense| "  #{describe(sense)}" }
    end

    def self.sentence_lines(sentence)
      senses = Sense.where(id: sentence.tokens.pluck("sense_id")).index_by(&:id)
      lines =
        sentence.tokens.each_with_index.map do |token, index|
          "  #{index} #{token_line(token, senses[token["sense_id"]])}"
        end

      ["Sentence #{sentence.id}: #{sentence.body}", *lines]
    end

    def self.token_line(token, sense)
      text = token["text"]
      outcome = token["outcome"] && " [#{token["outcome"]}]"
      return "#{text} → #{describe(sense)}#{outcome}" if sense
      return "#{text}: unresolved (#{token["note"]})" if token["note"]
      return "#{text}: not resolved yet" if text.match?(SnippetSentence::HAN)

      text
    end

    def self.describe(sense)
      entry = sense.entry

      "##{sense.id} #{entry.headword} #{entry.reading}: #{sense.gloss}"
    end
  end
end
