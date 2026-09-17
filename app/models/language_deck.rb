# frozen_string_literal: true

# Shared behavior for decks over a word_list: one class per language skill
# (Reading, Writing; someday Listening, Speaking). Never instantiated
# directly. Its cards are not rows: each is one entry the list selects,
# read from the compendium and scored by the owner's skill_scores, so the
# study seam is answered by one grouped query over the list's memberships.
class LanguageDeck < Deck
  ENTRY_COLUMNS = <<~SQL.squish
    entries.*,
    STRING_AGG(senses.gloss, '; ' ORDER BY sense_memberships.position)
      AS back,
    ARRAY_AGG(senses.id ORDER BY sense_memberships.position) AS sense_ids,
    (ARRAY_AGG(sense_memberships.category
      ORDER BY sense_memberships.position))[1] AS category,
    MIN(COALESCE(skill_scores.correct_streak, 0)) AS correct_streak
  SQL
  SCORES_JOIN = <<~SQL.squish
    LEFT JOIN skill_scores ON skill_scores.sense_id = senses.id
      AND skill_scores.user_id = :user_id AND skill_scores.skill = :skill
  SQL
  LIST_ORDER = Arel.sql("MIN(sense_memberships.position)")
  STREAK = "MIN(COALESCE(skill_scores.correct_streak, 0))"

  def self.model_name
    Deck.model_name
  end

  delegate :name, :language, to: :word_list

  def mandarin? = language == "zh"

  def generates_distractors? = true

  def card(id) = LanguageCard.new(self, entries.find(id))

  def study_pool(limit:)
    pool = entries.having("#{STREAK} < ?", level).order(LIST_ORDER)
    cards_from(pool.limit(limit))
  end

  def all_done? = rows(entries.having("#{STREAK} < ?", level)).none?

  def backs(except: nil, category: nil)
    scope = entries
    scope = scope.where.not(entries: { id: except.id }) if except
    scope = scope.where(entries: { id: entry_ids_filed(category) }) if category
    rows(scope).pluck(:back)
  end

  def cards_in_order(limit: nil)
    cards_from(entries.order(LIST_ORDER).limit(limit))
  end

  def cards_count = self[:cards_count] || rows(entries).count

  def done_count
    self[:done_count] || rows(entries.having("#{STREAK} >= ?", level)).count
  end

  def reading_pairs(except:)
    siblings = entries.where.not(entries: { id: except.id })
    rows(siblings).pluck(:headword, :reading)
  end

  def readings?
    rows(entries.where.not(entries: { reading: [nil, ""] })).exists?
  end

  def hanzi_chars
    @hanzi_chars ||=
      rows(entries).pluck(:headword).join.scan(/\p{Han}/).uniq.join
  end

  def homograph?(card)
    twins = entries.where(entries: { headword: card.front })
      .where.not(entries: { id: card.id })
    rows(twins).exists?
  end

  # Backs of the given entries as this list shows them now; an entry the
  # list no longer holds is absent.
  def backs_of(entry_ids)
    rows(entries.where(entries: { id: entry_ids })).pluck(:back)
  end

  # The member senses of every entry whose back reads exactly as the text;
  # a chosen option arrives as text, so this is how a miss finds its senses.
  def sense_ids_shown_as(text)
    rows(entries).where(back: text).pluck(:sense_ids).flatten
  end

  private

  # A guest's deck covers only the first entries in list order.
  def entries
    scope = list_entries
    return scope unless card_limit

    capped = rows(scope.order(LIST_ORDER).limit(card_limit)).select(:id)
    scope.where(entries: { id: capped })
  end

  def list_entries
    Entry.joins(senses: :sense_memberships)
      .joins(self.class.sanitize_sql_array([SCORES_JOIN, { user_id:, skill: }]))
      .where(sense_memberships: { word_list_id: })
      .group("entries.id")
      .select(ENTRY_COLUMNS)
  end

  def rows(scope) = Entry.from(scope, :entries)

  def cards_from(scope) = scope.map { |entry| LanguageCard.new(self, entry) }

  def entry_ids_filed(category)
    word_list.sense_memberships.where(category:)
      .joins(:sense).select("senses.entry_id")
  end
end
