# frozen_string_literal: true

class TextCard < Card
  validate(:example_pair_complete)

  def self.model_name
    Card.model_name
  end

  private

  def example_pair_complete
    return if example_front.present? == example_back.present?

    missing = example_front.present? ? :example_back : :example_front
    errors.add(missing, :blank)
  end
end
