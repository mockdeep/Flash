# frozen_string_literal: true

require "rails_helper"

RSpec.describe CardDistractor do
  it { is_expected.to belong_to(:card) }
  it { is_expected.to validate_presence_of(:text) }
end
