# frozen_string_literal: true

class MusicCard < Card
  NOTE_REGEXP = /\A[A-G]#?[1-8]\z/

  validates :back, format: { with: NOTE_REGEXP }

  def self.model_name
    Card.model_name
  end
end
