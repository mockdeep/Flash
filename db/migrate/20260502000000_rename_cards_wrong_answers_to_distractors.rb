# frozen_string_literal: true

class RenameCardsWrongAnswersToDistractors < ActiveRecord::Migration[8.1]
  def change
    safety_assured { rename_column :cards, :wrong_answers, :distractors }
  end
end
