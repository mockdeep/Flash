# frozen_string_literal: true

class MusicCard < Card
  NOTE_REGEXP = /\A[A-G]#?[1-8]\z/
  SEQUENCE_REGEXP = /\A[A-G]#?[1-8](,[A-G]#?[1-8])*\z/

  validates :back, format: { with: SEQUENCE_REGEXP }

  def self.model_name
    Card.model_name
  end
end
