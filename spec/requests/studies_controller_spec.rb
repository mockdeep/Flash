# frozen_string_literal: true

RSpec.describe StudiesController do
  describe "#show" do
    it "renders the study page" do
      deck = create(:deck)
      create(:card, deck:)
      login_as(default_user)

      get(deck_study_path(deck))

      expect(rendered).to have_content("cards done")
    end

    it "prevents viewing another user's deck" do
      other_deck = create(:deck, user: create(:user))
      login_as(default_user)

      get(deck_study_path(other_deck))

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "#update" do
    def submit_answer(deck:, card:, answer:)
      possible = ["Paris", "London", "Berlin", "Rome"]
      params = {
        answer: {
          card_id: card.id,
          answer:,
          possible_answers: possible,
        },
      }
      patch(deck_study_path(deck), params:)
    end

    context "when answer is correct" do
      it "increments correct count" do
        deck = create(:deck)
        card = create(:card, deck:, back: "Paris", correct_count: 0)
        login_as(default_user)

        expect { submit_answer(deck:, card:, answer: "Paris") }
          .to change_record(card, :correct_count).from(0).to(1)
      end

      it "increments correct streak" do
        deck = create(:deck)
        card = create(:card, deck:, back: "Paris", correct_streak: 0)
        login_as(default_user)

        expect { submit_answer(deck:, card:, answer: "Paris") }
          .to change_record(card, :correct_streak).from(0).to(1)
      end

      it "highlights the correct answer" do
        deck = create(:deck)
        card = create(:card, deck:, back: "Paris")
        login_as(default_user)

        submit_answer(deck:, card:, answer: "Paris")

        expect(rendered).to have_css(".answer-correct", text: "Paris")
      end

      it "fades the other answers" do
        deck = create(:deck)
        card = create(:card, deck:, back: "Paris")
        login_as(default_user)

        submit_answer(deck:, card:, answer: "Paris")

        expect(rendered).to have_css(".answer-faded", text: "London")
      end
    end

    context "when answer is incorrect" do
      it "resets correct streak" do
        deck = create(:deck)
        card = create(:card, deck:, back: "Paris", correct_streak: 5)
        login_as(default_user)

        expect { submit_answer(deck:, card:, answer: "London") }
          .to change_record(card, :correct_streak).to(0)
      end

      it "adds wrong answer to card" do
        deck = create(:deck)
        card = create(:card, deck:, back: "Paris")
        login_as(default_user)

        expect { submit_answer(deck:, card:, answer: "London") }
          .to change_record(card, :wrong_answers).from([]).to(["London"])
      end

      it "marks the wrong answer" do
        deck = create(:deck)
        card = create(:card, deck:, back: "Paris")
        login_as(default_user)

        submit_answer(deck:, card:, answer: "London")

        expect(rendered).to have_css(".answer-incorrect", text: "London")
      end

      it "highlights the correct answer" do
        deck = create(:deck)
        card = create(:card, deck:, back: "Paris")
        login_as(default_user)

        submit_answer(deck:, card:, answer: "London")

        expect(rendered).to have_css(".answer-correct", text: "Paris")
      end
    end
  end
end
