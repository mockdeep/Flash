# frozen_string_literal: true

namespace(:snippets) do
  desc("Process every unprocessed snippet (or ID=… alone) through Claude")
  task(process: :environment) do
    id = ENV.fetch("ID", nil)
    sentences = id ? Snippet.find(id).sentences : SnippetSentence.all

    Snippets::Process.call(sentences:) { |line| puts(line) }
    puts("Nothing left to process")
  end

  desc("Report a snippet (ID=…, FROM=…, TO=…) or every unfinished one")
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
