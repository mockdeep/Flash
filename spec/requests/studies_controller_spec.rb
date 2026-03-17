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
    end

    it "does not show the demo banner" do
      create(:card, deck:)
      get(deck_study_path(deck))

      expect(rendered).to have_no_css(".demo-banner")
    end

    context "when visiting on a new day" do
      before do
        card = create(:card, :active, deck:, back: "Paris")
        submit_answer(card:, answer: "London")
        travel_to(1.day.from_now)
        get(deck_study_path(deck))
      end

      it "resets completed counter" do
        expect(rendered).to have_content("0 / 50 completed")
      end
    end

    context "when reset_session param is present" do
      before do
        card = create(:card, :active, deck:, back: "Paris", correct_streak: 0)
        create(:card, :active, deck:)
        submit_answer(card:, answer: "Paris")
        get(deck_study_path(deck, reset_session: true))
      end

      it "resets completed counter" do
        expect(rendered).to have_content("0 / 50 completed")
      end
    end

    context "when returning after reaching milestone" do
      before do
        cards =
          50.times.map do
            create(:card, deck:, back: "Paris", correct_streak: 0)
          end
        create(:card, deck:)
        cards.each { |card| submit_answer(card:, answer: "Paris") }
        get(deck_study_path(deck))
      end

      it "resets completed counter" do
        expect(rendered).to have_content("0 / 50 completed")
      end
    end

    it "prevents viewing another user's deck" do
      other_deck = create(:deck, user: create(:user))

      get(deck_study_path(other_deck))

      expect(response).to have_http_status(:not_found)
    end

    it "shows deck complete message when all cards are done" do
      create(:card, :done, deck:)
      get(deck_study_path(deck))

      expect(rendered).to have_css("h2", text: "Deck Complete!")
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
        guest_deck = Deck.last
        follow_redirect!
        guest_deck.cards.first.update!(correct_streak: 0, status: "pending")
        create_list(:card, 49, deck: guest_deck, back: "A", correct_streak: 0)
        guest_deck.cards.reload.each do |card|
          patch(
            deck_study_path(guest_deck),
            params: {
              answer: {
                card_id: card.id,
                answer: "A",
                possible_answers: ["A", "B", "C", "D"],
              },
            },
          )
        end
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
    it "increments completed counter when card becomes done" do
      card = create(:card, :active, deck:, back: "Paris", correct_streak: 0)
      submit_answer(card:, answer: "Paris")

      expect(rendered).to have_content("1 / 50 completed")
    end

    context "when completed reaches 50" do
      before do
        cards =
          50.times.map do
            create(:card, deck:, back: "Paris", correct_streak: 0)
          end
        cards.each { |card| submit_answer(card:, answer: "Paris") }
      end

      it "shows milestone prompt", :aggregate_failures do
        expect(rendered).to have_content("You've completed 50 cards")
        expect(rendered).to have_link("Keep Going")
        expect(rendered).to have_link("Done for Now")
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

    it "prevents updating another user's deck" do
      other_deck = create(:deck, user: create(:user))

      patch(deck_study_path(other_deck), params: { answer: {} })

      expect(response).to have_http_status(:not_found)
    end
  end

  context "when not authenticated" do
    before { delete(session_path) }

    it "redirects #show to sign in" do
      get(deck_study_path(deck))

      expect(response).to redirect_to(new_session_path)
    end

    it "redirects #update to sign in" do
      patch(deck_study_path(deck), params: { answer: {} })

      expect(response).to redirect_to(new_session_path)
    end
  end
end
