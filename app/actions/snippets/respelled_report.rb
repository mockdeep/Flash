# frozen_string_literal: true

module Snippets
  # The report's Respelled lines: each spelling not yet settled, once, with
  # how often it stands for each headword, and "new" where the headword's
  # sense was made for it.
  module RespelledReport
    def self.call(sentences)
      rows =
        sentences.flat_map do |sentence|
          sentence.tokens.each_index.filter_map do |index|
            row(sentence, index)
          end
        end

      rows.group_by(&:first).map do |text, uses|
        "  #{text} → #{headwords(uses)}"
      end
    end

    def self.row(sentence, index)
      occurrence = Occurrence.new(sentence:, index:)
      token = sentence.tokens[index]
      return unless sentence.needs_sense?(token)
      return unless occurrence.unsettled_spelling?

      [occurrence.word.downcase, occurrence.headword, token["outcome"]]
    end

    def self.headwords(uses)
      forms =
        uses.group_by(&:second).map do |headword, same|
          fresh = " new" if same.map(&:third).include?("created")
          "#{headword} (#{same.size})#{fresh}"
        end

      forms.join(", ")
    end
  end
end
