# frozen_string_literal: true

# Shared behavior for decks over a word_list: one class per language skill
# (Reading, Writing; someday Listening, Speaking). Never instantiated
# directly. Its cards are not rows: each is one entry the list selects (in
# traditional, one spelling of it), read from the compendium and scored by
# the owner's skill_scores, so the study seam is answered by one grouped
# query over the list's memberships.
class LanguageDeck < Deck
  SCRIPTS = ["simplified", "traditional"].freeze
  ENTRY_COLUMNS = <<~SQL.squish
    entries.*,
    STRING_AGG(senses.gloss, '; ' ORDER BY sense_memberships.position)
      AS back,
    ARRAY_AGG(senses.id ORDER BY sense_memberships.position) AS sense_ids,
    ARRAY_TO_STRING(
      ARRAY_AGG(senses.id ORDER BY sense_memberships.position), '-'
    ) AS card_id,
    (ARRAY_AGG(sense_memberships.category
      ORDER BY sense_memberships.position))[1] AS category,
    MIN(COALESCE(skill_scores.correct_streak, 0)) AS correct_streak,
    MIN(COALESCE(skill_scores.view_count, 0)) AS view_count
  SQL
  SCORES_JOIN = <<~SQL.squish
    LEFT JOIN skill_scores ON skill_scores.sense_id = senses.id
      AND skill_scores.user_id = :user_id AND skill_scores.skill = :skill
  SQL
  SIMPLIFIED_FORM = Arel.sql("entries.headword")
  TRADITIONAL_FORM = Arel.sql("COALESCE(senses.traditional, entries.headword)")
  LIST_ORDER = Arel.sql("MIN(sense_memberships.position)")
  STREAK = "MIN(COALESCE(skill_scores.correct_streak, 0))"
  NOT_CORRECT_TODAY = "COALESCE(MAX(skill_scores.last_correct_at) < ?, TRUE)"

  def self.model_name
    Deck.model_name
  end

  delegate :language, to: :word_list

  validates :script, inclusion: { in: SCRIPTS }

  def name = [word_list.name, snippet&.label].compact.join(" · ")

  def mandarin? = language == "zh"

  def traditional? = script == "traditional"

  def generates_distractors? = true

  # A card's id is its senses' ids joined, so it finds the card holding them.
  def card(id)
    LanguageCard.new(self, holding(Sense.where(id: id.to_s.split("-"))).take!)
  end

  # A card waits for tomorrow once any of its senses was answered correctly
  # today, in this deck or another.
  def study_pool(limit:)
    pool = entries.having("#{STREAK} < ?", round).order(LIST_ORDER)
    pool = pool.having(NOT_CORRECT_TODAY, Date.current.beginning_of_day)
    cards_from(pool.limit(limit))
  end

  def not_done_count(at_round)
    rows(entries.having("#{STREAK} < ?", at_round)).count
  end

  def backs(except: nil, category: nil)
    scope = category ? holding(senses_filed(category)) : rows(entries)
    scope = scope.where.not(card_id: except.id) if except
    scope.pluck(:back)
  end

  def cards_in_order(limit: nil)
    cards_from(entries.order(LIST_ORDER).limit(limit))
  end

  def reading_pairs(except:)
    rows(entries).where.not(card_id: except.id).pluck(:form, :reading)
  end

  def readings?
    rows(entries.where.not(entries: { reading: [nil, ""] })).exists?
  end

  def hanzi_chars
    @hanzi_chars ||= rows(entries).pluck(:form).join.scan(/\p{Han}/).uniq.join
  end

  def homograph?(card)
    twins = entries.where(shown_form.eq(card.form))
    rows(twins).where.not(card_id: card.id).exists?
  end

  # Backs of the cards holding the given senses as this list shows them now;
  # a sense the list no longer holds is absent.
  def backs_of(sense_ids) = holding(Sense.where(id: sense_ids)).pluck(:back)

  # The member senses of every card whose back reads exactly as the text;
  # a chosen option arrives as text, so this is how a miss finds its senses.
  def sense_ids_shown_as(text)
    candidates = holding(senses_glossed_within(text))
    candidates.where(back: text).pluck(:sense_ids).flatten
  end

  private

  # A guest's deck covers only the first cards in list order.
  def entries
    scope = list_entries
    return scope unless card_limit

    capped = rows(scope.order(LIST_ORDER).limit(card_limit)).select(:id, :form)
    card_key = Arel::Nodes::Grouping.new([Entry.arel_table[:id], shown_form])
    scope.where(Arel::Nodes::In.new(card_key, capped.arel))
  end

  def list_entries
    Entry.joins(senses: :sense_memberships)
      .joins(self.class.sanitize_sql_array([SCORES_JOIN, { user_id:, skill: }]))
      .where(sense_memberships: { word_list_id: })
      .merge(studied_senses)
      .group("entries.id", shown_form)
      .select(ENTRY_COLUMNS, shown_form.as("form"))
  end

  # In traditional, an entry whose meanings are spelled apart (gan "dry" and
  # gan "to concern") makes a card per spelling.
  def shown_form = traditional? ? TRADITIONAL_FORM : SIMPLIFIED_FORM

  def rows(scope) = Entry.from(scope, :entries)

  # The cards holding any of the senses; grouping only their entries spares
  # grouping the whole list.
  def holding(senses)
    scope = entries.where(entries: { id: senses.select(:entry_id) })
    rows(scope).where("entries.sense_ids && ARRAY(?)", senses.select(:id))
  end

  def count_progress = rows(entries).pick(*progress_counts)

  def lowest_streak = rows(entries).minimum(:correct_streak)

  def cards_from(scope) = scope.map { |entry| LanguageCard.new(self, entry) }

  def senses_filed(category)
    word_list.senses.where(sense_memberships: { category: })
  end

  def senses_glossed_within(text)
    word_list.senses.where("position(senses.gloss IN ?) > 0", text)
  end
end
