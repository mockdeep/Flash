# frozen_string_literal: true

class TextDeck < Deck
  def self.model_name
    Deck.model_name
  end

  def reversible? = true
end
