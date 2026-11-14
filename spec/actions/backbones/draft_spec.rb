# frozen_string_literal: true

RSpec.describe Backbones::Draft do
  def answer = { title: "Casa", translation: "House", text: "A casa." }
  def text(**) = Backbones::Draft::Text.new(**answer, **)
  def original = file_fixture("backbones/tale/original/I.txt").read

  def draft(code = "B1", **)
    backbone = tale_backbone
    llm.answer(answer)

    described_class.call(backbone, backbone.level(code), "I", **)
  end

  def prompt = JSON.parse(llm.calls.sole.prompt)

  describe ".call" do
    it "asks Opus" do
      draft

      expect(llm.calls.sole.model).to eq("claude-opus-5-5")
    end

    it "names the work, its author and its language" do
      draft

      expect(llm.calls.sole.system).to include("O Conto by Ana Autora")
    end

    it "gives the level and its guidelines" do
      draft

      expect(prompt).to include("level" => "B1", "guidelines" => "Past tenses.")
    end

    it "gives the book's notes" do
      draft

      expect(prompt["notes"]).to eq("Keep the narrator's jokes.")
    end

    it "gives the words that pass" do
      draft("A1")
      story = ["hospício", "louco"]
      passing = { "story_words" => story, "title_words" => ["dr"] }

      expect(prompt).to include(passing)
    end

    it "writes the top level from the original" do
      draft
      above = { "version" => "original", "title" => "Um", "text" => original }

      expect(prompt["above"]).to eq(above)
    end

    it "writes a level from the level above" do
      draft("A1")

      expect(prompt["above"]).to include("version" => "B1", "title" => nil)
    end

    it "gives the draft it revises" do
      draft(revising: text(text: "A rua."), feedback: {})

      expect(prompt["draft"]).to include("text" => "A rua.")
    end

    it "gives the feedback" do
      draft(revising: text, feedback: { above_level: ["rua"] })

      expect(prompt["feedback"]).to eq("above_level" => ["rua"])
    end

    it "gives the new text and its heading" do
      expect(draft).to eq(text)
    end
  end
end
