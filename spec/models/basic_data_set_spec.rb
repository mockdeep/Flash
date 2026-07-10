# frozen_string_literal: true

require "rails_helper"

RSpec.describe BasicDataSet do
  it "forbids a language" do
    expect(described_class.new).not_to allow_value("zh").for(:language)
  end
end
