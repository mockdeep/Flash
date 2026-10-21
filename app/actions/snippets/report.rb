# frozen_string_literal: true

module Snippets
  # A snippet as a review sees it, as plain text: a summary line, the title
  # and heading translations, the words left unresolved and the senses
  # created, then every sentence token by token, with the sentence ids, token
  # indexes and sense ids that Snippets::Review takes. Sentences are numbered
  # from 1, and `from:` / `to:` keep to those numbers so a long snippet can be
  # reviewed a stretch at a time; the summary and created senses still cover
  # the whole snippet. The source's front matter, while unfinished, comes
  # first, marked by its role, since it is finished along with the snippet.
  module Report
    def self.call(snippet, from: 1, to: nil)
      front = snippet.source.front_matter.reject { it.status == :finished }
      all = snippet.sentences.to_a
      placed = [*front.map { [it, it.role] }, *numbered(all, from, to)]
      lines = placed.flat_map { sentence_lines(*it) }

      [*summary(snippet, front + all, placed.map(&:first)), *lines].join("\n")
    end

    # Each sentence in the stretch with its place in the snippet, "12/412".
    def self.numbered(all, from, to)
      all.each.with_index(1).filter_map do |sentence, number|
        [sentence, "#{number}/#{all.size}"] if (from..to).cover?(number)
      end
    end

    def self.summary(snippet, all, sentences)
      tokens = all.flat_map(&:tokens)

      [
        heading(snippet, tokens),
        *section("Translations", translations(snippet)),
        *section("Unresolved", unresolved(sentences)),
        *section("Created", created(tokens)),
        *section("Skipped", skipped(sentences)),
      ]
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

    # Shown under the titles where their words can't be looked up, such as
    # deck names. A missing one is flagged here rather than blocking Finish.
    def self.translations(snippet)
      source = snippet.source
      title = "source #{source.id} title #{source.title}"
      lines = [translation_line(title, source.title_translation)]
      return lines if snippet.heading.blank?

      heading = "snippet #{snippet.id} heading #{snippet.heading}"
      [*lines, translation_line(heading, snippet.heading_translation)]
    end

    def self.translation_line(label, translation)
      "  #{label}: #{translation.presence || "missing"}"
    end

    def self.section(title, lines)
      lines.empty? ? [] : ["#{title}:", *lines]
    end

    def self.unresolved(sentences)
      sentences.flat_map do |sentence|
        sentence.tokens.each_with_index.filter_map do |token, index|
          next unless token["outcome"] == "unresolved"

          "  sentence #{sentence.id} token #{index} #{token["text"]}: " \
            "#{token["note"]}"
        end
      end
    end

    def self.skipped(sentences)
      sentences.flat_map do |sentence|
        sentence.tokens.each_with_index.filter_map do |token, index|
          next unless token["skip"]

          "  sentence #{sentence.id} token #{index} #{token["text"]}: " \
            "#{token["skip"]}"
        end
      end
    end

    def self.created(tokens)
      created = tokens.select { |token| token["outcome"] == "created" }
      senses = Sense.where(id: created.pluck("sense_id")).order(:id)

      senses.map { |sense| "  #{describe(sense)}" }
    end

    def self.sentence_lines(sentence, place)
      senses = Sense.where(id: sentence.tokens.pluck("sense_id")).index_by(&:id)
      lines =
        sentence.tokens.each_with_index.map do |token, index|
          sense = senses[token["sense_id"]]
          "  #{index} #{token_line(sentence, token, sense)}"
        end

      ["Sentence #{sentence.id} (#{place}): #{sentence.body}", *lines]
    end

    def self.token_line(sentence, token, sense)
      text = token["text"]
      outcome = token["outcome"] && " [#{token["outcome"]}]"
      return "#{text} → #{describe(sense)}#{outcome}" if sense
      return "#{text}: unresolved (#{token["note"]})" if token["note"]
      return "#{text}: skipped (#{token["skip"]})" if token["skip"]
      return "#{text}: not resolved yet" if sentence.needs_sense?(token)

      text
    end

    # A traditional form that differs from the headword follows it.
    def self.describe(sense)
      entry = sense.entry
      traditional = sense.traditional
      traditional = nil if traditional == entry.headword
      spelled = traditional&.then { "(#{it})" }

      word = [entry.term, spelled, entry.reading].compact_blank.join(" ")

      "##{sense.id} #{word}: #{sense.gloss}"
    end
  end
end
