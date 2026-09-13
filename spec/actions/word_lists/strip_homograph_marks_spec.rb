# frozen_string_literal: true

require "rails_helper"

RSpec.describe WordLists::StripHomographMarks do
  def item(word_list, text, reading)
    create(:item, word_list:, text:, reading:)
  end

  # A marked front beside its bare twin, as the catalog emits them.
  def twins(marked, reading, bare:, bare_reading:)
    word_list = create(:word_list)
    item(word_list, bare, bare_reading)
    item(word_list, marked, reading)
  end

  it "strips a tone superscript" do
    marked = twins("过⁰", "guo", bare: "过", bare_reading: "guò")

    described_class.call(dry_run: false)

    expect(marked.reload.text).to eq("过")
  end

  it "strips a parenthesized reading" do
    marked = twins("重 (chóng)", "chóng", bare: "重", bare_reading: "zhòng")

    described_class.call(dry_run: false)

    expect(marked.reload.text).to eq("重")
  end

  it "reports each stripped front" do
    marked = twins("过⁰", "guo", bare: "过", bare_reading: "guò")

    report = described_class.call

    expect(report.stripped).to contain_exactly(
      have_attributes(id: marked.id, from: "过⁰", to: "过", reading: "guo"),
    )
  end

  it "writes nothing on a dry run" do
    marked = twins("过⁰", "guo", bare: "过", bare_reading: "guò")

    described_class.call

    expect(marked.reload.text).to eq("过⁰")
  end

  it "skips parens that don't hold the front's reading" do
    variant = twins("枪 (槍)", "qiāng", bare: "枪", bare_reading: "qiàng")

    report = described_class.call(dry_run: false)

    expect(report.skipped).to contain_exactly(
      have_attributes(id: variant.id, reason: :reading_mismatch),
    )
  end

  it "skips a marked front without a twin" do
    lone = item(create(:word_list), "过⁰", "guo")

    report = described_class.call(dry_run: false)

    expect(report.skipped).to contain_exactly(
      have_attributes(id: lone.id, reason: :no_twin),
    )
  end

  it "leaves other languages alone" do
    word_list = create(:word_list, language: "es")
    item(word_list, "el", nil)
    item(word_list, "el (m)", nil)

    expect(described_class.call).to have_attributes(stripped: [], skipped: [])
  end
end
