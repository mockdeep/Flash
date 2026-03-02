# frozen_string_literal: true

RSpec.describe StudiesController do
  let(:deck) { create(:deck) }

  before { login_as(default_user) }

  def submit_answer(card:, answer:)
    patch(
      deck_study_path(deck),
      params: {
        answer: {
          card_id: card.id,
          answer:,
          possible_answers: ["Paris", "London", "Berlin", "Rome"],
        },
      },
    )
  end

  def submit_demo_answer(deck: Deck.last)
    card = deck.cards.first
    answers = ["A", "B", "C", "D"]
    params = {
      answer: { card_id: card.id, answer: "wrong", possible_answers: answers },
    }
    patch(deck_study_path(deck), params:)
  end

  describe "#show" do
    it "renders the study page", :aggregate_failures do
      create(:card, deck:)
      get(deck_study_path(deck))

      expect(rendered).to have_content("completed")
      expect(rendered).to have_content("reviewed")
    end

    it "persists session counters across page refreshes" do
      card = create(:card, :active, deck:, back: "Paris")
      submit_answer(card:, answer: "London")
      get(deck_study_path(deck))

      expect(rendered).to have_content("1 / 100 reviewed")
    end

    context "when visiting on a new day" do
      before do
        card = create(:card, :active, deck:, back: "Paris")
        submit_answer(card:, answer: "London")
        travel_to(1.day.from_now)
        get(deck_study_path(deck))
      end

      it "resets completed counter" do
        expect(rendered).to have_content("0 / 25 completed")
      end

      it "resets reviewed counter" do
        expect(rendered).to have_content("0 / 100 reviewed")
      end
    end

    context "when reset_session param is present" do
      before do
        card = create(:card, :active, deck:, back: "Paris", correct_streak: 0)
        create(:card, :active, deck:)
        submit_answer(card:, answer: "Paris")
        get(deck_study_path(deck, reset_session: true))
      end

      it "resets reviewed counter" do
        expect(rendered).to have_content("0 / 100 reviewed")
      end

      it "resets completed counter" do
        expect(rendered).to have_content("0 / 25 completed")
      end
    end

    context "when completed reaches 25" do
      before do
        cards =
          25.times.map do
            create(:card, deck:, back: "Paris", correct_streak: 0)
          end
        create(:card, deck:)
        cards.each { |card| submit_answer(card:, answer: "Paris") }
        get(deck_study_path(deck))
      end

      it "adds complete class to completed bar" do
        expect(rendered).to have_css(".session-progress-bar-complete")
      end
    end

    it "prevents viewing another user's deck" do
      other_deck = create(:deck, user: create(:user))

      get(deck_study_path(other_deck))

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "demo mode" do
    let(:demo_owner) { create(:user) }
    let(:demo_deck) { create(:deck, :demo, user: demo_owner) }

    before do
      create(:card, deck: demo_deck, front: "Q", back: "A")
      post(demo_path, params: { deck_id: demo_deck.id })
    end

    it "shows demo banner on the study page" do
      follow_redirect!

      expect(rendered).to have_css(".demo-banner")
    end

    it "does not show demo banner after answering" do
      follow_redirect!
      submit_demo_answer

      expect(rendered).to have_no_css(".demo-banner")
    end

    context "when reaching the milestone" do
      before do
        100.times { submit_demo_answer }
      end

      it "shows sign up link" do
        expect(rendered).to have_link("Sign Up Free")
      end

      it "does not show done for now link" do
        expect(rendered).to have_no_link("Done for Now")
      end
    end
  end

  describe "#update" do
    it "increments reviewed counter on each answer" do
      card = create(:card, :active, deck:, back: "Paris")
      submit_answer(card:, answer: "London")
      submit_answer(card:, answer: "London")

      expect(rendered).to have_content("2 / 100 reviewed")
    end

    it "increments completed counter when card becomes done" do
      card = create(:card, :active, deck:, back: "Paris", correct_streak: 0)
      submit_answer(card:, answer: "Paris")

      expect(rendered).to have_content("1 / 25 completed")
    end

    it "shows milestone prompt when reviewed reaches 100",
       :aggregate_failures do
      card = create(:card, :active, deck:, back: "Paris")
      100.times { submit_answer(card:, answer: "London") }

      expect(rendered).to have_content("You've reviewed 100 cards")
      expect(rendered).to have_link("Keep Going")
      expect(rendered).to have_link("Done for Now")
    end

    context "when completed reaches 25" do
      before do
        cards =
          25.times.map do
            create(:card, deck:, back: "Paris", correct_streak: 0)
          end
        cards.each { |card| submit_answer(card:, answer: "Paris") }
      end

      it "adds complete class to completed bar" do
        expect(rendered).to have_css(".session-progress-bar-complete")
      end
    end

    context "when answer is correct" do
      it "increments correct count" do
        card = create(:card, deck:, back: "Paris", correct_count: 0)

        expect { submit_answer(card:, answer: "Paris") }
          .to change_record(card, :correct_count).from(0).to(1)
      end

      it "increments correct streak" do
        card = create(:card, deck:, back: "Paris", correct_streak: 0)

        expect { submit_answer(card:, answer: "Paris") }
          .to change_record(card, :correct_streak).from(0).to(1)
      end

      it "highlights the correct answer" do
        card = create(:card, deck:, back: "Paris")
        submit_answer(card:, answer: "Paris")

        expect(rendered).to have_css(".answer-correct", text: "Paris")
      end

      it "fades the other answers" do
        card = create(:card, deck:, back: "Paris")
        submit_answer(card:, answer: "Paris")

        expect(rendered).to have_css(".answer-faded", text: "London")
      end
    end

    context "when answer is incorrect" do
      it "resets correct streak" do
        card = create(:card, deck:, back: "Paris", correct_streak: 5)

        expect { submit_answer(card:, answer: "London") }
          .to change_record(card, :correct_streak).to(0)
      end

      it "adds wrong answer to card" do
        card = create(:card, deck:, back: "Paris")

        expect { submit_answer(card:, answer: "London") }
          .to change_record(card, :wrong_answers).from([]).to(["London"])
      end

      it "marks the wrong answer" do
        card = create(:card, deck:, back: "Paris")
        submit_answer(card:, answer: "London")

        expect(rendered).to have_css(".answer-incorrect", text: "London")
      end

      it "highlights the correct answer" do
        card = create(:card, deck:, back: "Paris")
        submit_answer(card:, answer: "London")

        expect(rendered).to have_css(".answer-correct", text: "Paris")
      end
    end
  end
end
