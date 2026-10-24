# frozen_string_literal: true

module Compendium
  # The prompt for reviewing a batch of entries, with nothing said twice:
  # each sentence and word list appears once, and senses point at them by
  # id, the ids a suggested edit names. Entries sharing a headword come
  # together, since a fix often moves a sense from one to another. A sense
  # shows at most USES of the sentences that use it, plus how many there
  # are.
  module Briefing
    USES = 5

    def self.call(entries)
      senses = entries.flat_map { it.senses.order(:id) }
      uses = senses.index_with { sample(it) }

      {
        sentences: uses.values.flatten.uniq.map { sentence_prompt(it) },
        lists: holding(senses).map { { id: it.id, name: it.name } },
        headwords: headword_prompts(entries, uses),
      }
    end

    def self.holding(senses) = senses.flat_map(&:word_lists).uniq

    def self.sample(sense)
      SnippetSentence.pointing_at(sense)
        .order(:source_id, :snippet_id, :position)
        .limit(USES)
        .to_a
    end

    def self.sentence_prompt(sentence)
      {
        id: sentence.id,
        source_id: sentence.source_id,
        before: neighbour(sentence, -1),
        text: sentence.body,
        after: neighbour(sentence, 1),
      }.compact
    end

    # Front matter belongs to no snippet, so has no neighbours.
    def self.neighbour(sentence, offset)
      return unless sentence.snippet

      position = sentence.position + offset
      sentence.snippet.sentences.find_by(position:)&.body
    end

    def self.headword_prompts(entries, uses)
      grouped = entries.group_by { [it.language, it.headword] }

      grouped.map do |(language, headword), group|
        { language:, headword:, entries: group.map { entry_prompt(it, uses) } }
      end
    end

    def self.entry_prompt(entry, uses)
      senses = entry.senses.order(:id).map { sense_prompt(it, uses[it]) }

      { id: entry.id, term: entry.term, reading: entry.reading, senses: }
        .compact
    end

    def self.sense_prompt(sense, sample)
      {
        id: sense.id,
        gloss: sense.gloss,
        traditional: sense.traditional,
        examples: sense.sense_examples.order(:id).map { example_prompt(it) },
        lists: sense.sense_memberships.map { list_use(it) },
        uses: sample.map { use(sense, it) },
        use_count: SnippetSentence.pointing_at(sense).count,
      }.compact
    end

    def self.example_prompt(example)
      { sentence: example.sentence, translation: example.translation }.compact
    end

    def self.list_use(membership)
      { list_id: membership.word_list_id, category: membership.category }
        .compact
    end

    def self.use(sense, sentence)
      tokens =
        sentence.tokens.each_index.select do |index|
          sentence.tokens[index]["sense_id"] == sense.id
        end

      { sentence_id: sentence.id, tokens: }
    end
  end
end
