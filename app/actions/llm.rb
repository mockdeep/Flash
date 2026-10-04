# frozen_string_literal: true

# Structured questions to Claude for the content pipeline. Callers ask
# `Llm.client.call(model:, system:, prompt:, schema:)` and get back a hash
# that fits the schema, or an Llm::Error. The client is set per environment:
# the Claude CLI in development, a fake in specs, and none in production,
# which never calls an LLM.
module Llm
  SONNET = "claude-sonnet-5-5"
  OPUS = "claude-opus-5-5"

  class Error < StandardError; end

  class << self
    attr_writer :client
  end

  def self.client = @client || raise(Error, "No LLM is used in #{Rails.env}")
end
