# frozen_string_literal: true

class MusicDeck < Deck
  after_initialize(:default_distractor_pool)

  def self.model_name
    Deck.model_name
  end

  def music? = true

  def card_type = "MusicCard"

  def flat_cards? = true

  def type_label = "Practice"

  private

  def default_distractor_pool
    self.distractor_pool ||= "none"
  end
end
