# frozen_string_literal: true

# Another way a text writes an entry's word, kept in lower case: "sya" for
# "siya". One is recorded when a reviewed snippet is finished, so a spelling
# is judged and reviewed once rather than at every use.
class Spelling < ApplicationRecord
  belongs_to :entry

  validates :entry, :text, presence: true
  validates :text, uniqueness: { scope: :entry_id }

  normalizes :text, with: ->(value) { value.downcase }

  # Whether a spelling can be taken as this headword without a judge: it
  # stands for that one word alone, and isn't a word of its own. "yung" can
  # be two words and "ng" is one already, so each use of those is still
  # checked.
  def self.settled?(language, text, headword)
    written = text.downcase
    entries = Entry.where(language:)
    forms = entries.joins(:spellings).where(spellings: { text: written })

    forms.distinct.pluck(:headword) == [headword] &&
      !entries.exists?(headword: written)
  end
end
