# frozen_string_literal: true

module Snippets
  # One Han token of a sentence, with what the compendium holds for it.
  # Every token is its own occurrence, so a word used in two senses, even
  # within one sentence, is decided twice. `rejection` keeps why a proposal
  # for it did not stand, and carries it to the next rung of the ladder.
  class Occurrence
    MARKS = ["【", "】"].freeze
    CONTEXT = 3

    attr_reader :sentence, :index
    attr_accessor :rejection

    # The Han tokens of a sentence batch, one occurrence per token.
    def self.for(sentences)
      sentences.flat_map do |sentence|
        sentence.tokens.each_with_index.filter_map do |token, index|
          new(sentence:, index:) if token["text"].match?(SnippetSentence::HAN)
        end
      end
    end

    def initialize(sentence:, index:)
      @sentence = sentence
      @index = index
    end

    def key = [sentence, index]

    def word = sentence.tokens[index]["text"]

    # A word as written and the headword it was given: one traditional form
    # can stand for two simplified words in one text.
    def spelling = [word, headword]

    # The simplified form the token studies under, which the segmenter gave
    # where it differs from the text.
    def headword = sentence.tokens[index]["simplified"] || word

    # Read afresh on every call: a sense created for an earlier token is there
    # for the next rung to pick.
    def senses
      Sense.joins(:entry)
        .where(entries: { language: Snippet::LANGUAGE, headword: })
        .order(:id).to_a
    end

    # This one occurrence: which sentence and word it is (ids into the
    # briefing's lists) and where in the sentence it stands. The word is
    # named as well as pointed at, so a question says what it is about and a
    # muddled id shows up as a mismatch instead of a quietly wrong sense.
    def to_prompt(id, sid:, wid:)
      { id:, sid:, wid:, word:, marked:, rejection: }.compact
    end

    # What holds for every occurrence of the word, said once per briefing.
    def word_prompt(wid)
      {
        wid:,
        word:,
        headword:,
        senses: senses.map { |sense| sense_prompt(sense) },
      }
    end

    private

    def words = sentence.tokens.pluck("text")

    # The token marked among its neighbours, which is what tells two uses of
    # one word in a sentence apart. A window rather than the whole sentence,
    # which the briefing gives once.
    def marked
      from = [index - CONTEXT, 0].max

      words[from..(index + CONTEXT)].each_with_index.sum("") do |text, offset|
        from + offset == index ? "#{MARKS.first}#{text}#{MARKS.last}" : text
      end
    end

    def sense_prompt(sense)
      entry = sense.entry

      {
        id: sense.id,
        headword: entry.headword,
        reading: entry.reading,
        gloss: sense.gloss,
      }
    end
  end
end
