# frozen_string_literal: true

RSpec.describe Views::Studies::Update do
  def render_view(deck:, result:)
    view = described_class.new(deck:, result:)
    Phlex::Testing::Nokogiri.render(view)
  end

  describe "#view_template" do
    it "shows progress bar with current deck status" do
      deck = create(:deck)
      create(:card, :done, deck:)
      result = double("Result", question: "Question", correct?: true, correct_answer: "Answer")

      html = render_view(deck:, result:)
      progress = html.css("progress").first

      expect(progress["value"]).to eq("1")
      expect(progress["max"]).to eq("1")
    end

    it "displays progress text" do
      deck = create(:deck)
      create(:card, :done, deck:)
      create(:card, :pending, deck:)
      result = double("Result", question: "Question", correct?: true, correct_answer: "Answer")

      html = render_view(deck:, result:)

      expect(html.css(".progress-text").text).to include("1 / 2 cards done")
    end

    it "displays question from result" do
      deck = create(:deck)
      result = double("Result", question: "Test Question", correct?: true, correct_answer: "Answer")

      html = render_view(deck:, result:)

      expect(html.css(".card-front").text).to eq("Test Question")
    end

    context "when result is correct" do
      it "shows correct result card with checkmark" do
        deck = create(:deck)
        result = double("Result", question: "Q", correct?: true, correct_answer: "Right Answer")

        html = render_view(deck:, result:)

        correct_card = html.css(".result-correct").first
        expect(correct_card.css(".result-icon").text).to eq("✓")
        expect(correct_card.css("h2").text).to eq("Correct!")
      end

      it "displays the correct answer" do
        deck = create(:deck)
        result = double("Result", question: "Q", correct?: true, correct_answer: "Right Answer")

        html = render_view(deck:, result:)

        answer_display = html.css(".answer-display strong").text
        expect(answer_display).to eq("Right Answer")
      end
    end

    context "when result is incorrect" do
      it "shows incorrect result card with X mark" do
        deck = create(:deck)
        result = double("Result", question: "Q", correct?: false, correct_answer: "Right Answer")

        html = render_view(deck:, result:)

        incorrect_card = html.css(".result-incorrect").first
        expect(incorrect_card.css(".result-icon").text).to eq("✗")
        expect(incorrect_card.css("h2").text).to eq("Not quite")
      end

      it "displays the correct answer" do
        deck = create(:deck)
        result = double("Result", question: "Q", correct?: false, correct_answer: "Right Answer")

        html = render_view(deck:, result:)

        correct_answer = html.css(".correct-answer strong").text
        expect(correct_answer).to eq("Right Answer")
      end
    end

    it "renders next card button with space hotkey" do
      deck = create(:deck)
      result = double("Result", question: "Q", correct?: true, correct_answer: "Answer")

      html = render_view(deck:, result:)

      next_button = html.css(".next-card-button").first
      expect(next_button["data-hotkey"]).to eq(" ")
      expect(next_button.css("span").first.text).to eq("Next Card")
      expect(next_button.css(".hotkey-hint").text).to eq("Press Space")
    end
  end
end