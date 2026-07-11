# frozen_string_literal: true

# Plain forward flashcards over a BasicDataSet: no language features, no
# reverse form.
class BasicDeck < Deck
  def self.model_name
    Deck.model_name
  end

  def card_type = "BasicCard"

  def type_label = "Basic"

  def replaceable? = true
end
