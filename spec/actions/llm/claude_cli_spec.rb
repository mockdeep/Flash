# frozen_string_literal: true

require "rails_helper"

RSpec.describe Llm::ClaudeCli do
  def ask(prompt = "Hello", schema: { type: "object" })
    executable = file_fixture("fake_claude").realpath.to_s
    client = described_class.new(executable:)

    client.call(model: Llm::SONNET, system: "Be brief.", prompt:, schema:)
  end

  def logged
    output = StringIO.new
    logger = ActiveSupport::Logger.new(output)
    Rails.logger.broadcast_to(logger)
    yield
    output.string
  ensure
    Rails.logger.stop_broadcasting_to(logger)
  end

  describe "#call" do
    it "sends the prompt on stdin" do
      expect(ask("Hello")["prompt"]).to eq("Hello")
    end

    it "asks in headless mode for JSON fitting the schema" do
      expect(ask(schema: { type: "array" })["arguments"]).to start_with(
        "-p", "--output-format", "json", "--json-schema", '{"type":"array"}'
      )
    end

    it "passes the system prompt and model" do
      expect(ask["arguments"]).to include(
        "--system-prompt", "Be brief.", "--model", "claude-sonnet-5-5"
      )
    end

    it "keeps tools, settings and session history out of the run" do
      expect(ask["arguments"]).to end_with(
        "--tools", "", "--setting-sources", "", "--no-session-persistence"
      )
    end

    it "keeps the API key from the CLI so it bills the subscription" do
      expect(ask["api_key"]).to be_nil
    end

    it "runs outside the project, away from its CLAUDE.md" do
      expect(ask["directory"]).to eq(File.realpath(Dir.tmpdir))
    end

    it "logs the tokens the call used" do
      expect(logged { ask }).to include("[llm] claude-sonnet-5-5")
    end

    it "raises with the error output when the CLI fails" do
      expect { ask("exit loudly") }.to raise_error(Llm::Error, /boom/)
    end

    it "raises with the regular output when the error output is empty" do
      expect { ask("exit quietly") }.to raise_error(Llm::Error, /quiet/)
    end

    it "raises when the output is not JSON" do
      expect { ask("not json") }
        .to raise_error(Llm::Error, /something other than JSON/)
    end

    it "raises when the CLI reports an error" do
      expect { ask("is error") }
        .to raise_error(Llm::Error, /error_max_turns cut off/)
    end

    it "raises when the answer has no structured output" do
      expect { ask("no answer") }.to raise_error(Llm::Error, /success chat/)
    end
  end
end
