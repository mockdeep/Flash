# frozen_string_literal: true

RSpec.describe Views::Studies::Show do
  def render_view(deck:, study:)
    view = described_class.new(deck:, study:)
    Phlex::Testing::Nokogiri.render(view)
  end

  describe "#view_template" do
    it "renders deck navigation links" do
      deck = create(:deck)
      study = double("Study", next_card: create(:card, deck:), possible_answers: ["Answer 1"])

      html = render_view(deck:, study:)

      expect(html.css("a[href*='#{deck.id}']")).to be_present
      expect(html.css("a[href='/decks']")).to be_present
    end

    it "displays deck name as heading" do
      deck = create(:deck, name: "Test Deck")
      study = double("Study", next_card: create(:card, deck:), possible_answers: ["Answer 1"])

      html = render_view(deck:, study:)

      expect(html.css("h1").text).to include("Test Deck")
    end

    it "shows progress bar with correct values" do
      deck = create(:deck)
      create(:card, :done, deck:)
      create(:card, :pending, deck:)
      study = double("Study", next_card: create(:card, deck:), possible_answers: ["Answer 1"])

      html = render_view(deck:, study:)
      progress = html.css("progress").first

      expect(progress["value"]).to eq("1")
      expect(progress["max"]).to eq("3")
    end

    it "displays progress text" do
      deck = create(:deck)
      create(:card, :done, deck:)
      study = double("Study", next_card: create(:card, deck:), possible_answers: ["Answer 1"])

      html = render_view(deck:, study:)

      expect(html.css(".progress-text").text).to include("1 / 2 cards done")
    end

    it "renders card front as heading" do
      deck = create(:deck)
      card = create(:card, deck:, front: "Question Text")
      study = double("Study", next_card: card, possible_answers: ["Answer 1"])

      html = render_view(deck:, study:)

      expect(html.css(".card-front").text).to eq("Question Text")
    end

    it "creates answer buttons with hotkey data" do
      deck = create(:deck)
      card = create(:card, deck:)
      study = double("Study", next_card: card, possible_answers: ["First", "Second"])

      html = render_view(deck:, study:)

      buttons = html.css("button.answer-button")
      expect(buttons.length).to eq(2)

      expect(buttons[0]["data-hotkey"]).to eq("1")
      expect(buttons[1]["data-hotkey"]).to eq("2")
    end

    it "displays answer numbers and text in buttons" do
      deck = create(:deck)
      card = create(:card, deck:)
      study = double("Study", next_card: card, possible_answers: ["First Answer"])

      html = render_view(deck:, study:)

      button = html.css("button.answer-button").first
      number = button.css(".answer-number").text
      text = button.css(".answer-text").text

      expect(number).to eq("1")
      expect(text).to eq("First Answer")
    end
  end
end