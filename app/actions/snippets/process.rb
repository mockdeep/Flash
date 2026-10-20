# frozen_string_literal: true

module Snippets
  # Works through every snippet that is not yet processed (or only the
  # `sentences:` given, such as one snippet's), a batch of
  # sentences at a time, saving each batch as it goes so a run that dies
  # picks up where it stopped: segment every sentence, then resolve them in
  # order, so later batches see the senses earlier ones created. Yields a
  # line for each batch it finishes and each sentence it sent back to the
  # segmenter, for the caller to report. A batch holds one language, since
  # the prompts it is asked under are that language's.
  module Process
    SEGMENT_BATCH = 10
    RESOLVE_BATCH = 2

    def self.call(sentences: SnippetSentence.all, &)
      segment(sentences, &)
      resolve(sentences, &)
    end

    def self.segment(sentences)
      loop do
        batch = sentences.unsegmented
          .order(:snippet_id, :position).limit(SEGMENT_BATCH).to_a
        break if batch.empty?

        by_language(batch).each do |run|
          Segment.call(run)
          yield(summary("Segmented", run)) if block_given?
        end
      end
    end

    def self.resolve(sentences, &)
      awaiting = sentences.segmented.order(:snippet_id, :position)
        .select(&:awaiting_senses?)
      runs = by_language(awaiting)
      runs.flat_map { it.each_slice(RESOLVE_BATCH).to_a }.each do |batch|
        complaints = Resolve.call(batch)
        report(batch, complaints, &) if block_given?
      end
    end

    def self.by_language(sentences)
      sentences.slice_when { |one, other| one.language != other.language }
    end

    def self.report(batch, complaints)
      complaints.each do |sentence, complaint|
        yield("Re-segmented #{sentence.body} (#{complaint})")
      end
      yield(summary("Resolved", batch))
    end

    def self.summary(step, batch)
      titles = batch.map { |sentence| sentence.snippet.title }.uniq

      "#{step} #{batch.size} sentences of #{titles.join(", ")}"
    end
  end
end
