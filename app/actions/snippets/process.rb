# frozen_string_literal: true

module Snippets
  # Works through every snippet that is not yet processed, a batch of
  # sentences at a time, saving each batch as it goes so a run that dies
  # picks up where it stopped: segment every sentence, then resolve them in
  # order, so later batches see the senses earlier ones created. Yields each
  # step and the batch it finished, for the caller to report.
  module Process
    SEGMENT_BATCH = 10
    RESOLVE_BATCH = 2

    def self.call(&)
      segment(&)
      resolve(&)
    end

    def self.segment
      loop do
        batch = SnippetSentence.unsegmented
          .order(:snippet_id, :position).limit(SEGMENT_BATCH).to_a
        break if batch.empty?

        Segment.call(batch)
        yield(:segmented, batch) if block_given?
      end
    end

    def self.resolve
      SnippetSentence.segmented.order(:snippet_id, :position)
        .select(&:awaiting_senses?).each_slice(RESOLVE_BATCH) do |batch|
          Resolve.call(batch)
          yield(:resolved, batch) if block_given?
        end
    end
  end
end
