# frozen_string_literal: true

namespace(:snippets) do
  desc("Process every snippet not yet processed, through the Claude CLI")
  task(process: :environment) do
    Snippets::Process.call { |line| puts(line) }
    puts("Nothing left to process")
  end
end
