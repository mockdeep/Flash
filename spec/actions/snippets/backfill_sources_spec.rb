# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::BackfillSources do
  def snippet(word_list, title, **details)
    create(:snippet, word_list:, title:, **details)
  end

  def spring_festival(**details)
    word_list = create(:word_list, name: "春节")
    snippet(word_list, "春节：习俗", **details)
  end

  it "gives a list a source named after it" do
    spring_festival

    described_class.call(dry_run: false)

    expect(Source.last).to have_attributes(title: "春节")
  end

  it "carries the snippets' details onto the source" do
    url = "https://zh.wikipedia.org/zh-cn/春节"
    spring_festival(author: "维基百科", source_url: url, license: "cc_by_sa")

    described_class.call(dry_run: false)

    expect(Source.last.slice(:author, :source_url, :license))
      .to eq("author" => "维基百科", "source_url" => url, "license" => "cc_by_sa")
  end

  it "puts each snippet under its list's source" do
    snippet = spring_festival

    described_class.call(dry_run: false)

    expect(snippet.reload.source).to eq(snippet.word_list.source)
  end

  it "makes a title prefixed with the list's name a heading" do
    snippet = spring_festival

    described_class.call(dry_run: false)

    expect(snippet.reload.heading).to eq("习俗")
  end

  it "keeps any other title whole as the heading" do
    snippet = create(:snippet, title: "孔乙己")

    described_class.call(dry_run: false)

    expect(snippet.reload.heading).to eq("孔乙己")
  end

  it "adds a new snippet to the source its list already has" do
    source = create(:source)
    snippet = create(:snippet, word_list: source.word_list)

    described_class.call(dry_run: false)

    expect(snippet.reload.source).to eq(source)
  end

  it "skips a list whose snippets disagree on their details" do
    snippet = spring_festival(author: "维基百科")
    snippet(snippet.word_list, "春节：名称", author: "鲁迅")

    expect(described_class.call(dry_run: false).skipped).to eq(["春节"])
  end

  it "reports the sources it makes and the headings it gives" do
    spring_festival

    expect(described_class.call)
      .to have_attributes(sources: ["春节"], headings: { "春节：习俗" => "习俗" })
  end

  it "writes nothing on a dry run" do
    spring_festival

    expect { described_class.call }.not_to change(Source, :count)
  end
end
