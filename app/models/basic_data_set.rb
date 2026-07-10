# frozen_string_literal: true

class BasicDataSet < DataSet
  validates :language, absence: true

  def deck_classes = [BasicDeck]
end
