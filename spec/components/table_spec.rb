# frozen_string_literal: true

RSpec.describe Components::Table do
  def render_for(rows)
    described_class.new(headings: ["Word", "Gloss"], rows:).call do |table, row|
      row.each { |text| table.cell { text } }
    end
  end

  it "renders each heading" do
    expect(render_for([])).to include(%(<th class="table__heading">Gloss</th>))
  end

  it "renders a row per item" do
    html = render_for([["花", "flower"], ["买", "to buy"]])

    expect(html.scan(%(<tr class="table__row">)).size).to eq(2)
  end

  it "renders the cells the block asks for" do
    html = render_for([["花", "flower"]])

    expect(html).to include(%(<td class="table__cell">flower</td>))
  end

  it "html-escapes cell content" do
    expect(render_for([["<script>", "x"]])).not_to include("<script>")
  end
end
