# frozen_string_literal: true

class MusicDeck < Deck
  after_initialize(:default_distractor_pool)

  def self.model_name
    Deck.model_name
  end

  def music? = true

  private

  def default_distractor_pool
    self.distractor_pool ||= "none"
  end
end
