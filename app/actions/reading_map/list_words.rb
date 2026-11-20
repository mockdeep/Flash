# frozen_string_literal: true

module ReadingMap
  # A word list's words as a level list may hold them, names left out. Each
  # word is its spellings: the headword and, where Lemmas knows the language
  # and the list has a text to read the word in, its base form (a
  # contraction's parts, all of which a level must hold) and any other
  # headword for it. Base forms are asked only for words the level lists
  # (`known`) don't hold as written, and a word the answer calls a name, a
  # numeral or an interjection is left out too.
  module ListWords
    NAME = "proper noun"
    NAMED = "BOOL_OR(sense_memberships.category = '#{NAME}')".freeze

    def self.call(word_list, known:)
      words = headwords(word_list)
      unknown = words.reject { |_, headword| known.include?(headword) }
      base_forms = base_forms(word_list, unknown.keys)

      words.filter_map do |id, headword|
        spellings(headword, base_forms[id])
      end
    end

    # Nil for a word the answer says isn't one to look for in a list.
    def self.spellings(headword, word)
      return [[headword]] if word.nil? || word.unknown?
      return unless word.word?

      alternatives = word.alternatives.map { [it] }
      [[headword], word.lemmas.presence, *alternatives].compact
    end

    # Each entry the list holds that isn't filed as a name, in lower case.
    def self.headwords(word_list)
      Entry.joins(senses: :sense_memberships)
        .where(sense_memberships: { word_list: })
        .group(:id).having("NOT COALESCE(#{NAMED}, FALSE)")
        .pluck(:id, "LOWER(entries.headword)").to_h
    end

    def self.base_forms(word_list, entry_ids)
      language = word_list.language
      return {} if Lemmas::LANGUAGES.exclude?(language)

      uses = first_uses(word_list, entry_ids)
      uses.keys.zip(Lemmas.in(language).for(uses.values)).to_h
    end

    # Each entry's word as the list's source first writes it, with the
    # sentence that does.
    def self.first_uses(word_list, entry_ids)
      entries = Sense.where(entry_id: entry_ids).pluck(:id, :entry_id).to_h
      sentences = SnippetSentence.where(source: word_list.source).order(:id)

      sentences.each_with_object({}) do |sentence, uses|
        sentence.tokens.each do |token|
          entry = entries[token["sense_id"]]
          uses[entry] ||= [token["text"], sentence.body] if entry
        end
      end
    end
  end
end
