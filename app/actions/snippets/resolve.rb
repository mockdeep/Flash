# frozen_string_literal: true

module Snippets
  # Resolves a batch of segmented sentences: every Han token is matched to a
  # compendium sense, given a new one, or left unresolved with the reason.
  # Tokens without a Han character are left as they are.
  #
  # New senses escalate up a ladder, each rung's judge sitting at or above
  # its proposer; an occurrence still rejected at the top stays unresolved.
  # A sentence with a token called missegmented goes back to the segmenter
  # once, with the complaint, and is resolved afresh; complained about
  # again, its fragments stay unresolved. Senses its other tokens created on
  # the first pass stay in the compendium, unused unless a token picks them.
  module Resolve
    RUNGS = [
      { proposer: Llm::SONNET, judge: Llm::OPUS },
      { proposer: Llm::OPUS, judge: Llm::OPUS },
    ].freeze
    # Every token is an occurrence, and a long sentence holds dozens, so a
    # call is sized by tokens rather than sentences to keep its answer under
    # the output limit. A slice goes up the whole ladder and is recorded
    # before the next begins, so later slices see the senses earlier ones
    # created.
    OCCURRENCE_BATCH = 25

    # Returns the complaints that sent sentences back to the segmenter.
    def self.call(sentences, resegment: true)
      results = {}
      Occurrence.for(sentences).each_slice(OCCURRENCE_BATCH) do |slice|
        results.merge!(escalate(slice))
      end
      faulted = resegment ? complaints(sentences, results) : {}
      (sentences - faulted.keys).each { |sentence| save(sentence, results) }

      resegment(faulted)
    end

    def self.resegment(faulted)
      if faulted.any?
        Segment.call(faulted.keys, feedback: faulted)
        call(faulted.keys, resegment: false)
      end
      faulted
    end

    # What each sentence's missegmented tokens were said to get wrong.
    def self.complaints(sentences, results)
      faulted =
        sentences.filter_map do |sentence|
          notes = faults(sentence, results)
          [sentence, notes.join("; ")] if notes.any?
        end
      faulted.to_h
    end

    def self.faults(sentence, results)
      sentence.tokens.each_index.filter_map do |index|
        result = results.fetch([sentence, index], {})
        next unless result["outcome"] == "missegmented"

        "#{sentence.tokens[index]["text"]}: #{result["note"]}"
      end
    end

    def self.save(sentence, results)
      tokens =
        sentence.tokens.each_with_index.map do |token, index|
          token.merge(settled(results.fetch([sentence, index], {})))
        end
      sentence.update!(tokens:)
    end

    def self.settled(result)
      return result unless result["outcome"] == "missegmented"

      result.merge("outcome" => "unresolved")
    end

    def self.escalate(occurrences)
      results = {}
      waiting =
        RUNGS.reduce(occurrences) do |remaining, rung|
          results.merge!(attempt(remaining, **rung))
          remaining.reject { |occurrence| results.key?(occurrence.key) }
        end

      results.merge(waiting.to_h { [it.key, unresolved(it)] })
    end

    def self.unresolved(occurrence)
      { "outcome" => "unresolved", "note" => occurrence.rejection }
    end

    def self.attempt(occurrences, proposer:, judge:)
      proposals = Propose.call(occurrences, model: proposer)
      new_senses, settled = proposals.partition(&:new_sense?)
      accepted = Judge.call(new_senses, model: judge)

      (settled + accepted).to_h do |proposal|
        [proposal.occurrence.key, Record.call(proposal)]
      end
    end
  end
end
