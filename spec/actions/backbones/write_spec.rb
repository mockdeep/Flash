# frozen_string_literal: true

RSpec.describe Backbones::Write do
  def draft(text, title: "Casa") = { title:, translation: "T", text: }
  def pass(*problems) = { verdict: "PASS", problems: }
  def rework = { verdict: "REWORK", problems: [problem] }

  def problem
    { quote: "A", category: "story", why: "Unclear", replacement: "O" }
  end

  # The writer and the reviewer answer in turn from their queues, after the
  # first lemma answers given as unanswered.
  def answer(drafts, reviews, unanswered)
    llm.respond do |call|
      if lemma_call?(call)
        (unanswered -= 1).negative? ? lemma_answer(call) : { words: [] }
      else
        (review_call?(call) ? reviews : drafts).shift
      end
    end
  end

  def write(*drafts, reviews: [], unanswered: 0)
    backbone = tale_backbone
    tale_list("A1", "casa", "a", "velha")
    tale_list("B1", "rua")
    answer(drafts, reviews, unanswered)
    lemmas = Backbones::Lemmas.new(Backbone::CACHE.join("lemmas.json"))

    described_class.call(backbone, backbone.level("A1"), "I", lemmas:)
  end

  def writer_prompts
    llm.calls.reject { lemma_call?(it) || review_call?(it) }
      .map { JSON.parse(it.prompt) }
  end

  def reviews = llm.calls.count { review_call?(it) }
  def text_of(...) = write(...).draft.text

  describe ".call" do
    it "is done when the draft is within the level and passes" do
      expect(write(draft("A casa."), reviews: [pass])).to be_done
    end

    it "gives the draft" do
      expect(text_of(draft("A casa."), reviews: [pass])).to eq("A casa.")
    end

    it "logs each step" do
      log = write(draft("A casa."), reviews: [pass]).log

      expect(log).to include("Drafted", "Checked: clean", "Review 1: PASS")
    end

    it "revises a draft with words above the level" do
      drafts = [draft("A rua."), draft("A casa.")]

      expect(text_of(*drafts, reviews: [pass])).to eq("A casa.")
    end

    it "tells the writer the words above the level" do
      write(draft("A rua."), draft("A casa."), reviews: [pass])
      above = [{ "word" => "rua", "written" => ["rua"] }]

      expect(writer_prompts.second["feedback"]).to eq("above_level" => above)
    end

    it "checks the title too" do
      outcome = write(draft("A.", title: "Rua"), draft("A."), reviews: [pass])

      expect(outcome.draft.title).to eq("Casa")
    end

    it "stops when words are still above the level after the last round" do
      outcome = write(*Array.new(4) { draft("A rua.") })

      expect(outcome.trouble).to eq("above the level after 3 rounds: rua")
    end

    it "is done when the last round brings the draft within the level" do
      above = draft("A rua.")
      drafts = [above, above, above, draft("A casa.")]

      expect(write(*drafts, reviews: [pass])).to be_done
    end

    it "applies a PASS's fixes" do
      drafts = [draft("A."), draft("A casa.")]

      expect(text_of(*drafts, reviews: [pass(problem)])).to eq("A casa.")
    end

    it "doesn't review a PASS's fixes" do
      write(draft("A."), draft("A casa."), reviews: [pass(problem)])

      expect(reviews).to eq(1)
    end

    it "gives the writer the review's problems" do
      write(draft("A."), draft("A casa."), reviews: [pass(problem)])
      problems = [problem.stringify_keys]

      expect(writer_prompts.last["feedback"]).to eq("problems" => problems)
    end

    it "reviews a REWORK's fixes again" do
      write(draft("A."), draft("A casa."), reviews: [rework, pass])

      expect(reviews).to eq(2)
    end

    it "is done when the second review passes" do
      outcome = write(draft("A."), draft("A casa."), reviews: [rework, pass])

      expect(outcome).to be_done
    end

    it "stops when the second review still says REWORK" do
      outcome = write(draft("A."), draft("A."), reviews: [rework, rework])

      expect(outcome.trouble).to eq("REWORK after the second review")
    end

    it "stops when a fix brings back a word taken out" do
      drafts = [draft("A rua."), draft("A casa."), draft("A rua.")]
      outcome = write(*drafts, reviews: [rework])

      expect(outcome.trouble).to eq("a fix brought back rua")
    end

    it "revises a fix's words above the level" do
      drafts = [draft("A."), draft("A rua."), draft("A casa velha.")]

      expect(text_of(*drafts, reviews: [rework, pass])).to eq("A casa velha.")
    end

    it "checks again without revising when forms went unanswered" do
      write(draft("A casa."), reviews: [pass], unanswered: 1)

      expect(writer_prompts.size).to eq(1)
    end
  end
end
