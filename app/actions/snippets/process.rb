# frozen_string_literal: true

module Snippets
  # Works through every snippet that is not yet processed, a batch of
  # sentences at a time, saving each batch as it goes so a run that dies
  # picks up where it stopped. For now that means segmenting; yields each
  # batch it finishes, for the caller to report.
  module Process
    SEGMENT_BATCH = 10

    def self.call
      loop do
        batch = SnippetSentence.unsegmented
          .order(:snippet_id, :position).limit(SEGMENT_BATCH).to_a
        break if batch.empty?

        Segment.call(batch)
        yield(batch) if block_given?
      end
    end
  end
end
