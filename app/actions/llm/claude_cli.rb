# frozen_string_literal: true

require "open3"

module Llm
  # Asks through the Claude Code CLI in headless mode, so a run bills the
  # developer's subscription rather than API tokens. The API key is kept out
  # of the CLI's environment (it would otherwise bill the API), and setting
  # sources are off so no CLAUDE.md or memory reaches the prompt.
  class ClaudeCli
    EFFORT = "high"
    # A nil value removes the variable from the child's environment; leaving
    # it out of the hash would pass it through.
    ENVIRONMENT = { "ANTHROPIC_API_KEY" => nil }.freeze

    def initialize(executable: "claude")
      @executable = executable
    end

    def call(model:, system:, prompt:, schema:)
      output = run(model, arguments(model, system, schema), prompt)

      structured(JSON.parse(output), model)
    rescue JSON::ParserError => e
      raise(Error, "#{model} answered with something other than JSON: #{e}")
    end

    private

    def run(model, arguments, prompt)
      output, error, status = Open3.capture3(
        ENVIRONMENT,
        @executable,
        *arguments,
        stdin_data: prompt,
        chdir: Dir.tmpdir,
      )
      return output if status.success?

      raise(Error, "#{model}: #{error.presence || output}")
    end

    def arguments(model, system, schema)
      options = {
        "--output-format" => "json",
        "--json-schema" => schema.to_json,
        "--system-prompt" => system,
        "--model" => model,
        "--effort" => EFFORT,
        "--tools" => "",
        "--setting-sources" => "",
      }

      ["-p", *options.flatten, "--no-session-persistence"]
    end

    def structured(result, model)
      answer = result["structured_output"]
      if result["is_error"] || answer.nil?
        raise(Error, "#{model}: #{result["subtype"]} #{result["result"]}")
      end

      usage = result["usage"].to_h.slice("input_tokens", "output_tokens")
      Rails.logger.info("[llm] #{model} #{usage}")
      answer
    end
  end
end
