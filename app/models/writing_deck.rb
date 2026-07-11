# frozen_string_literal: true

# The reverse study of a language data_set: given a meaning, recall the
# target-language word and identify its written form. The Back items become
# prompts and their paired Front items the answers; it shares the source
# deck's data_set (no re-upload), only the direction differs.
class WritingDeck < LanguageDeck
  def name = "#{data_set.name} (reversed)"

  def card_type = "WritingCard"

  def type_label = "Writing"

  def type_position = 2

  def anchor_side = "Back"

  def anchor_pairing_column = :paired_item_id

  # The category lives on the answer (Front) item, so reach it through the
  # pairing: Front items in the category -> their paired Back items -> cards.
  def cards_in_category(category)
    front_ids = data_set.items.where(side: "Front", category:).select(:id)
    back_ids = Pairing.where(item_id: front_ids).select(:paired_item_id)
    cards.where(item_id: back_ids)
  end
end
