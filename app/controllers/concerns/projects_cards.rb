# frozen_string_literal: true

# Wraps card writes so the data_set projection stays in sync atomically.
module ProjectsCards
  extend ActiveSupport::Concern

  private

  def save_card(card)
    ActiveRecord::Base.transaction do
      next false unless card.update(card_params)

      DataSets::Projection.project_card(card)
      true
    end
  end

  def destroy_card(card)
    ActiveRecord::Base.transaction do
      DataSets::Projection.remove_card(card)
      card.destroy!
    end
  end
end
