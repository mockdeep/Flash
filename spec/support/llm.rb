# frozen_string_literal: true

module Helpers
  module LlmHelpers
    def llm = Llm.client
  end
end

RSpec.configure do |config|
  config.include(Helpers::LlmHelpers)
  config.before { Llm.client = Llm::Fake.new }
end
