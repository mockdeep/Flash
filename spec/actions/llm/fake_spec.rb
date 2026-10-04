# frozen_string_literal: true

require "rails_helper"

RSpec.describe Llm::Fake do
  def ask(fake, prompt: "Hello")
    fake.call(model: Llm::SONNET, system: "Be brief.", prompt:, schema: {})
  end

  it "hands back queued answers in order" do
    fake = described_class.new
    fake.answer({ "n" => 1 }, { "n" => 2 })
    ask(fake)

    expect(ask(fake)).to eq("n" => 2)
  end

  it "returns answers with string keys, as JSON would" do
    fake = described_class.new
    fake.answer({ greeting: "hi" })

    expect(ask(fake)).to eq("greeting" => "hi")
  end

  it "answers from a responder given the call" do
    fake = described_class.new
    fake.respond { |call| { "echo" => call.prompt } }

    expect(ask(fake, prompt: "ping")).to eq("echo" => "ping")
  end

  it "raises a queued failure" do
    fake = described_class.new
    fake.fail("overloaded")

    expect { ask(fake) }.to raise_error(Llm::Error, "overloaded")
  end

  it "raises when no answer is queued" do
    expect { ask(described_class.new) }
      .to raise_error(Llm::Error, /No answer queued/)
  end

  it "records each call" do
    fake = described_class.new
    fake.answer({})
    ask(fake, prompt: "ping")

    expect(fake.calls.sole.prompt).to eq("ping")
  end
end
