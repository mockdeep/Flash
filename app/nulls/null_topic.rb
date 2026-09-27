# frozen_string_literal: true

# Stands in for a topic over the decks that have none, so the decks index can
# treat them as one more section.
class NullTopic
  attr_accessor :user

  def initialize(user:)
    self.user = user
  end

  def name = "Other Decks"

  def decks = user.decks.where(topic: nil)
end
