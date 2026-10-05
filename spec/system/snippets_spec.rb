# frozen_string_literal: true

require "rails_helper"

RSpec.describe "snippets" do
  def glosses = { "我" => "I", "爱" => "to love", "你" => "you" }

  # Answers each pipeline step as a local run would get them: one word per
  # character, a new sense for every word, every sense accepted, and every
  # word a verb.
  def fake_pipeline
    llm.respond do |call|
      prompt = JSON.parse(call.prompt)

      case call.system
      when Snippets::Segment::SYSTEM then segmented(prompt)
      when Snippets::Propose::SYSTEM then proposed(prompt)
      when Snippets::Judge::SYSTEM then judged(prompt)
      else categorized(prompt)
      end
    end
  end

  def segmented(prompt)
    sentences =
      prompt.map do |row|
        words = row["sentence"].chars.map { { text: it, simplified: it } }
        { id: row["id"], words: }
      end
    { sentences: }
  end

  def proposed(prompt)
    decisions =
      prompt["occurrences"].map do |row|
        gloss = glosses[row["word"]]
        { id: row["id"], decision: "new", reading: "x", gloss: }
      end
    { decisions: }
  end

  def judged(prompt)
    { verdicts: prompt["occurrences"].map { { id: it["id"], accept: true } } }
  end

  def categorized(prompt)
    { categories: prompt.map { { id: it["id"], category: "verb" } } }
  end

  def add_snippet
    sign_in(create(:user, :admin))
    click_on("Snippets")
    click_on("Add a snippet")
    fill_in("Title", with: "Love")
    fill_in("Word List", with: "Love Letters")
    fill_in("Text", with: "我爱你。")
    click_on("Add Snippet")
  end

  # What a Claude Code session does locally: process, then finish.
  def process_and_finish
    fake_pipeline
    Snippets::Process.call
    Snippets::Finish.call(Snippet.sole)
    visit(snippets_path)
  end

  it "lists a new snippet" do
    add_snippet

    expect(page).to have_css("tr", text: "Love Love Letters New")
  end

  it "offers nothing to study before the snippet is finished" do
    add_snippet

    expect(page).to have_no_button("Study this list")
  end

  it "studies a finished snippet's list as a reading deck" do
    add_snippet
    process_and_finish

    click_on("Study this list")

    expect(page).to have_css("h1", text: "Love Letters")
  end

  it "fills the deck with the snippet's words" do
    add_snippet
    process_and_finish

    click_on("Study this list")

    expect(page).to have_css("td", text: "to love")
  end
end
