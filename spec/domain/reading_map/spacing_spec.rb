# frozen_string_literal: true

RSpec.describe ReadingMap::Spacing do
  def node(angle)
    ReadingMap::Chart::Node.new(
      word_list: build_stubbed(:word_list), ring: 1, angle:, heat: nil,
    )
  end

  def spaced(*angles, room: 10)
    described_class.call(angles.map { node(it) }, room:).map(&:angle)
  end

  it "leaves nodes with room where they are" do
    expect(spaced(90, 70, 110)).to eq([90, 70, 110])
  end

  it "moves a crowding node away from the center" do
    expect(spaced(90, 85)).to eq([90, 80])
  end

  it "moves a node on the higher side further up" do
    expect(spaced(90, 95)).to eq([90, 100])
  end

  it "moves a second node at the center to the higher side" do
    expect(spaced(90, 90)).to eq([90, 100])
  end

  it "keeps the node nearest the center where it is" do
    expect(spaced(60, 65)).to eq([65, 55])
  end

  it "moves a node past every node in its way" do
    expect(spaced(90, 85, 84)).to eq([90, 80, 70])
  end

  it "keeps the first of two nodes at one spot where it is" do
    nodes = [node(50), node(50)].sort_by { it.word_list.id }

    expect(described_class.call(nodes.reverse, room: 10).first)
      .to eq(nodes.first)
  end
end
