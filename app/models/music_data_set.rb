# frozen_string_literal: true

class MusicDataSet < DataSet
  validates :language, absence: true
end
