# frozen_string_literal: true

module Snippets
  # Resolves a batch of segmented sentences: every Han token is matched to a
  # compendium sense, given a new one, or left unresolved with the reason.
  # Sonnet proposes and Opus judges each new sense; tokens without a Han
  # character are left as they are.
  module Resolve
    PROPOSER = Llm::SONNET
    JUDGE = Llm::OPUS
    # Every token is an occurrence, and a long sentence holds dozens, so a
    # call is sized by tokens rather than sentences to keep its answer under
    # the output limit. A slice is recorded before the next begins, so later
    # slices see the senses earlier ones created.
    OCCURRENCE_BATCH = 25

    def self.call(sentences)
      results = {}
      Occurrence.for(sentences).each_slice(OCCURRENCE_BATCH) do |slice|
        results.merge!(attempt(slice))
      end

      sentences.each { |sentence| save(sentence, results) }
    end

    def self.save(sentence, results)
      tokens =
        sentence.tokens.each_with_index.map do |token, index|
          token.merge(results.fetch([sentence, index], {}))
        end
      sentence.update!(tokens:)
    end

    def self.attempt(occurrences)
      proposals = Propose.call(occurrences, model: PROPOSER)
      new_senses, settled = proposals.partition(&:new_sense?)
      accepted = Judge.call(new_senses, model: JUDGE)
      standing = (settled + accepted).index_by { |one| one.occurrence.key }

      occurrences.to_h do |occurrence|
        [occurrence.key, result(occurrence, standing[occurrence.key])]
      end
    end

    # A proposal that did not stand leaves the occurrence its rejection.
    def self.result(occurrence, proposal)
      return Record.call(proposal) if proposal

      { "outcome" => "unresolved", "note" => occurrence.rejection }
    end
  end
end
