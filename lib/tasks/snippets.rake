# frozen_string_literal: true

namespace(:snippets) do
  desc("Process every snippet not yet processed, through the Claude CLI")
  task(process: :environment) do
    Snippets::Process.call { |line| puts(line) }
    puts("Nothing left to process")
  end

  desc(
    "Report a snippet for review (ID=…), or every unfinished snippet; " \
    "FROM=… / TO=… show only those sentences",
  )
  task(review: :environment) do
    id = ENV.fetch("ID", nil)
    from = Integer(ENV.fetch("FROM", 1))
    to = ENV.fetch("TO", nil)&.then { Integer(it) }
    snippets =
      if id
        [Snippet.find(id)]
      else
        Snippet.order(:id).reject { |snippet| snippet.status == :finished }
      end

    snippets.each do |snippet|
      puts(Snippets::Report.call(snippet, from:, to:), "")
    end
    puts(Snippets::Report.unused)
  end
end
