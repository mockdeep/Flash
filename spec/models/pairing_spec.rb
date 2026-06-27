# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pairing do
  it { is_expected.to belong_to(:item) }
  it { is_expected.to belong_to(:paired_item).class_name("Item") }
end
