# frozen_string_literal: true

require "rails_helper"

RSpec.describe Llm::AskEach do
  def ask_each(items, prompt: [{ id: 0 }])
    options = { model: Llm::SONNET, system: "Be brief.", schema: {} }

    described_class.call(items, list: "rows", prompt:, **options)
  end

  it "returns the answer's rows keyed by id" do
    llm.answer({ rows: [{ id: 0, word: "我" }] })

    expect(ask_each(["我"])).to eq(0 => { "id" => 0, "word" => "我" })
  end

  it "sends the prompt as JSON" do
    llm.answer({ rows: [] })

    ask_each(["我"], prompt: [{ id: 0, sentence: "我" }])

    expect(llm.calls.sole.prompt).to eq('[{"id":0,"sentence":"我"}]')
  end

  it "asks nothing when there are no items" do
    ask_each([])

    expect(llm.calls).to be_empty
  end
end
