# frozen_string_literal: true

module Compendium
  # The prompt for reviewing a batch of entries, with nothing said twice:
  # each sentence and word list appears once, and senses point at them.
  # Entries sharing a headword come together, since a fix often moves a
  # sense from one to another. A sense shows at most USES of the sentences
  # that use it, plus how many there are.
  module Briefing
    USES = 5

    def self.call(entries)
      senses = entries.flat_map { it.senses.order(:id) }
      uses = senses.index_with { sample(it) }
      sentences = uses.values.flatten.uniq
      lists = holding(senses)

      {
        sentences: numbered(sentences) { |one, sid| sentence_prompt(one, sid) },
        lists: numbered(lists) { |list, lid| { lid:, name: list.name } },
        headwords: headword_prompts(entries, uses, sentences, lists),
      }
    end

    def self.numbered(list, &) = list.each_with_index.map(&)
    def self.holding(senses) = senses.flat_map(&:word_lists).uniq

    def self.sample(sense)
      SnippetSentence.pointing_at(sense)
        .order(:source_id, :snippet_id, :position)
        .limit(USES)
        .to_a
    end

    def self.sentence_prompt(sentence, sid)
      {
        sid:,
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

    def self.headword_prompts(entries, uses, sentences, lists)
      grouped = entries.group_by { [it.language, it.headword] }

      grouped.map do |(language, headword), group|
        prompts = group.map { entry_prompt(it, uses, sentences, lists) }

        { language:, headword:, entries: prompts }
      end
    end

    def self.entry_prompt(entry, uses, sentences, lists)
      senses =
        entry.senses.order(:id).map do |sense|
          sense_prompt(sense, uses[sense], sentences, lists)
        end

      { id: entry.id, term: entry.term, reading: entry.reading, senses: }
        .compact
    end

    def self.sense_prompt(sense, sample, sentences, lists)
      {
        id: sense.id,
        gloss: sense.gloss,
        traditional: sense.traditional,
        examples: sense.sense_examples.order(:id).map { example_prompt(it) },
        lists: sense.sense_memberships.map { list_use(it, lists) },
        uses: sample.map { use(sense, it, sentences) },
        use_count: SnippetSentence.pointing_at(sense).count,
      }.compact
    end

    def self.example_prompt(example)
      { sentence: example.sentence, translation: example.translation }.compact
    end

    def self.list_use(membership, lists)
      lid = lists.index(membership.word_list)

      { lid:, category: membership.category }.compact
    end

    def self.use(sense, sentence, sentences)
      tokens =
        sentence.tokens.each_index.select do |index|
          sentence.tokens[index]["sense_id"] == sense.id
        end

      { sid: sentences.index(sentence), tokens: }
    end
  end
end
