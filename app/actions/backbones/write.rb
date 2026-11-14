# frozen_string_literal: true

module Backbones
  # One chapter at one level, drafted, revised until no word is above the
  # level, then reviewed. A PASS's fixes are applied and checked; a
  # REWORK's are applied, checked and reviewed again. It stops for a
  # person when a second review still says REWORK, when words are above
  # the level after ROUNDS revisions, or when a review's fix brings back a
  # word the revisions took out.
  class Write
    ROUNDS = 3
    REVIEWS = 2
    LAST_REWORK = "REWORK after the second review"

    # The draft, why it stopped (nil when it is done) and what happened.
    Outcome = Data.define(:draft, :trouble, :log)

    class Outcome
      def done? = trouble.nil?
    end

    def self.call(...) = new(...).call

    def initialize(backbone, level, chapter, lemmas:)
      @backbone = backbone
      @level = level
      @chapter = chapter
      @lemmas = lemmas
      @log = []
      @removed = Set.new
    end

    def call
      draft = Draft.call(@backbone, @level, @chapter)
      note("Drafted", draft.text)
      draft, trouble = within_level(draft)
      return outcome(draft, trouble) if trouble

      reviewed(draft, 1)
    end

    private

    def reviewed(draft, count)
      review = review(draft, count)
      return outcome(draft) if review.pass? && review.problems.empty?
      return outcome(draft, LAST_REWORK) if !review.pass? && count == REVIEWS

      fixed, trouble = applied(draft, review)
      return outcome(fixed, trouble) if trouble || review.pass?

      reviewed(fixed, count + 1)
    end

    def review(draft, count)
      review = Review.call(@backbone, @level, @chapter, draft)
      note("Review #{count}: #{review.verdict}", review.problems.to_json)
      review
    end

    def applied(draft, review)
      feedback = { problems: review.problems.map(&:to_h) }
      fixed = revise(draft, feedback, "Applied review #{review.verdict}")
      result = check(fixed)
      back = flagged(result) & @removed.to_a
      return [fixed, "a fix brought back #{back.join(", ")}"] if back.any?

      within_level(fixed, result)
    end

    # The draft revised until no word is above the level, and why it stopped
    # if it never got there. A check whose only fault is forms unanswered
    # is simply made again, since they are asked again.
    def within_level(draft, result = check(draft))
      ROUNDS.times do
        return [draft, nil] if result.clean?

        draft = simpler(draft, result) if result.flags.any?
        result = check(draft)
      end
      return [draft, nil] if result.clean?

      [draft, "above the level after #{ROUNDS} rounds: #{words(result)}"]
    end

    def simpler(draft, result)
      @removed.merge(flagged(result))
      revise(draft, { above_level: above_level(result) }, "Revised words")
    end

    def revise(draft, feedback, label)
      revised = Draft.call(
        @backbone,
        @level,
        @chapter,
        revising: draft,
        feedback:,
      )
      note(label, revised.text)
      revised
    end

    def check(draft)
      text = "#{draft.title}\n\n#{draft.text}"
      result = Check.call(@backbone, @level, text, lemmas: @lemmas)
      note("Checked: #{result.clean? ? "clean" : words(result)}")
      result
    end

    def flagged(result) = result.flags.map(&:base)
    def words(result) = flagged(result).join(", ")

    def above_level(result)
      result.flags.map { { word: it.base, written: it.forms.keys } }
    end

    def note(label, detail = nil)
      @log << label
      @log << detail << "" if detail
    end

    def outcome(draft, trouble = nil)
      Outcome.new(draft:, trouble:, log: @log)
    end
  end
end
