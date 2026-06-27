# frozen_string_literal: true

# Edits and deletes write to the card's data_set items, not the card itself
# (the card is a thin progress anchor). Edit content comes from the form params;
# distractors aren't editable, so they're carried over from the existing item.
module ProjectsCards
  extend ActiveSupport::Concern

  private

  def save_card(card)
    content = edit_content(card)
    ActiveRecord::Base.transaction do
      next false unless valid_edit?(card, content)

      DataSets::Projection.project(card, content)
      true
    end
  end

  def destroy_card(card)
    ActiveRecord::Base.transaction do
      DataSets::Projection.remove_card(card)
      card.destroy!
    end
  end

  def edit_content(card)
    card_params.to_h.symbolize_keys.merge(distractors: card.distractors)
  end

  def valid_edit?(card, content)
    add_content_errors(card, content)
    card.errors.empty?
  end

  # All content (and its validation) moved off the card onto data_set items, so
  # the edit is validated here against the submitted content.
  def add_content_errors(card, content)
    card.errors.add(:front, :blank) if content[:front].blank?
    card.errors.add(:back, :blank) if content[:back].blank?
    add_example_pair_error(card, content)
    card.errors.add(:front, :taken) if front_collision?(card, content[:front])
  end

  def add_example_pair_error(card, content)
    front = content[:example_front]
    back = content[:example_back]
    return if front.present? == back.present?

    card.errors.add(front.present? ? :example_back : :example_front, :blank)
  end

  def front_collision?(card, front)
    front.present? && DataSets::Projection.front_taken?(card, front)
  end
end
