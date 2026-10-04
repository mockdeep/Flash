# frozen_string_literal: true

module Llm
  # The client specs use in place of Claude. It hands back queued answers in
  # order, or asks a responder block given the call, and records every call
  # so a spec can check what was asked. Answers go through JSON, so they
  # come back with string keys the way a real answer does.
  class Fake
    Call = Data.define(:model, :system, :prompt, :schema)

    attr_reader :calls

    def initialize
      @answers = []
      @calls = []
    end

    def answer(*answers) = @answers.concat(answers)

    def fail(message) = @answers << Error.new(message)

    def respond(&responder)
      @responder = responder
    end

    def call(model:, system:, prompt:, schema:)
      call = Call.new(model:, system:, prompt:, schema:)
      calls << call
      answer = @responder ? @responder.call(call) : next_answer
      raise(answer) if answer.is_a?(Error)

      JSON.parse(answer.to_json)
    end

    private

    def next_answer
      @answers.shift || raise(Error, "No answer queued for the fake LLM")
    end
  end
end
