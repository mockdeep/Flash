# frozen_string_literal: true

# A reverse deck studies an existing data_set in the opposite direction: the
# Back items become prompts and their paired Front items the answers. It shares
# the source deck's data_set (no re-upload); only the reading direction differs.
class ReverseTextDeck < TextDeck
  def card_type = "ReverseTextCard"

  def anchor_side = "Back"

  def anchor_pairing_column = :paired_item_id

  # A reverse of a reverse would just be the forward deck again.
  def reversible? = false

  # The category lives on the answer (Front) item, so reach it through the
  # pairing: Front items in the category -> their paired Back items -> cards.
  def cards_in_category(category)
    front_ids = data_set.items.where(side: "Front", category:).select(:id)
    back_ids = Pairing.where(item_id: front_ids).select(:paired_item_id)
    cards.where(item_id: back_ids)
  end
end
