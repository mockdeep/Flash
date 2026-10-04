# frozen_string_literal: true

namespace(:snippets) do
  desc("Process every snippet not yet processed, through the Claude CLI")
  task(process: :environment) do
    Snippets::Process.call do |step, batch|
      titles = batch.map { |sentence| sentence.snippet.title }.uniq
      puts("#{step.capitalize} #{batch.size} sentences of #{titles.join(", ")}")
    end
    puts("Nothing left to process")
  end
end
