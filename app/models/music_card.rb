# frozen_string_literal: true

class MusicCard < Card
  NOTE_REGEXP = /\A[A-G]#?[1-8]\z/

  def self.model_name
    Card.model_name
  end
end
