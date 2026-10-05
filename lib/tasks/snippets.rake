# frozen_string_literal: true

namespace(:snippets) do
  desc("Process every snippet not yet processed, through the Claude CLI")
  task(process: :environment) do
    Snippets::Process.call { |line| puts(line) }
    puts("Nothing left to process")
  end

  desc("Report a snippet for review (ID=…), or every unfinished snippet")
  task(review: :environment) do
    id = ENV.fetch("ID", nil)
    snippets =
      if id
        [Snippet.find(id)]
      else
        Snippet.order(:id).reject { |snippet| snippet.status == :finished }
      end

    snippets.each { |snippet| puts(Snippets::Report.call(snippet), "") }
    puts(Snippets::Report.unused)
  end
end
