# frozen_string_literal: true

# How far into its text a learner's study of a deck has reached: the
# furthest page a word they have seen first appears on. Pages change only
# when the text does, so each word's first page is cached per source.
class StudyPlace
  def initialize(deck)
    @deck = deck
  end

  # None for a deck without a text the learner may read, or before they
  # have seen any of its words.
  def page
    firsts = first_pages
    return if firsts.empty?

    seen = @deck.user.skill_scores
      .where(skill: @deck.skill, sense_id: firsts.keys, view_count: 1..)
      .pluck(:sense_id)
    firsts.values_at(*seen).max
  end

  private

  def first_pages
    source = @deck.source
    return {} unless source&.readable_by?(@deck.user)

    Rails.cache.fetch(cache_key(source)) do
      pages_by_sense(ReadingPages.for(@deck))
    end
  end

  # The page each word first appears on, by its sense.
  def pages_by_sense(pages)
    pages.each_with_object({}) do |page, firsts|
      page.tokens.each do |token|
        sense_id = token["sense_id"]
        firsts[sense_id] ||= page.number if sense_id
      end
    end
  end

  # A change to any of the text's sentences, or to the page length, makes
  # new pages.
  def cache_key(source)
    sentences = SnippetSentence.where(source_id: source.id)
    changed = sentences.maximum(:updated_at)&.iso8601(6)
    lengths = [ReadingPages::CHARACTERS, ReadingPages::WORDS]
    ["study_place", source.id, changed, sentences.count, *lengths]
  end
end
