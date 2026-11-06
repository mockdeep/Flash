# frozen_string_literal: true

module Snippets
  # The report's Cut differently lines: a word one sentence of the source
  # keeps whole and another cuts into neighbouring words, naming the
  # sentences in the stretch that do either, for Review.resegment.
  module CutReport
    LONGEST = 4

    def self.call(sentences, source)
      everywhere = SnippetSentence.where(source:).order(:id)
      wholes = places(everywhere) { whole_words(it) }
      cuts = places(everywhere) { cut_words(it) }
      ids = sentences.map(&:id)

      (wholes.keys & cuts.keys).flat_map do |text|
        lines(text, wholes[text], cuts[text], ids)
      end
    end

    # Where each word appears: its text, then sentence id => how it is shown.
    def self.places(sentences)
      sentences.each_with_object({}) do |sentence, found|
        yield(sentence).each do |text, shown|
          (found[text] ||= {})[sentence.id] = shown
        end
      end
    end

    def self.whole_words(sentence)
      runs(sentence).flatten.map { [it, it] }
    end

    # Every stretch of 2 to LONGEST neighbouring words, as the word they
    # would spell together and as its parts.
    def self.cut_words(sentence)
      joiner = sentence.language.spaces ? " " : ""

      runs(sentence).flat_map do |run|
        (2..LONGEST).flat_map do |size|
          run.each_cons(size).map { [it.join(joiner), it.join(" + ")] }
        end
      end
    end

    # The sentence's words in unbroken runs: punctuation or a skipped word
    # ends one.
    def self.runs(sentence)
      texts = sentence.tokens.map { sentence.needs_sense?(it) && it["text"] }

      texts.slice_when { |a, b| !a || !b }.select(&:first)
    end

    # Only the rarer form is likely a slip, so only its sentences are named;
    # both are when the source uses each as often.
    def self.lines(text, whole, cut, ids)
      parts = "cut #{cut.values.first}"
      cut_line = line(text, parts, cut.keys & ids, whole.keys, "whole")
      whole_line = line(text, "whole", whole.keys & ids, cut.keys, parts)
      rarer = { -1 => [cut_line], 1 => [whole_line] }

      rarer.fetch(cut.size <=> whole.size, [cut_line, whole_line]).compact
    end

    def self.line(text, here, ids, elsewhere, there)
      return if ids.empty?

      others = (elsewhere - ids).size

      "  #{text}: #{here} in #{"sentence".pluralize(ids.size)} " \
        "#{ids.join(", ")}; #{there} in #{others} #{"other".pluralize(others)}"
    end
  end
end
