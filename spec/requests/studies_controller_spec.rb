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

    it "shows filled stars for completed levels" do
      deck.update!(level: 3)
      create(:card, deck:)
      get(deck_study_path(deck))

      expect(rendered).to have_css(".star--filled", count: 2)
    end

    it "does not show the demo banner" do
      create(:card, deck:)
      get(deck_study_path(deck))

      expect(rendered).to have_no_css(".demo-banner")
    end

    context "when visiting on a new day" do
      before do
        card = create(:card, deck:, back: "Paris")
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
        card = create(:card, deck:, back: "Paris", correct_streak: 0)
        create(:card, deck:)
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

    it "shows empty deck message when no cards to study" do
      get(deck_study_path(deck))

      expect(rendered).to have_css("h2", text: "No cards to study")
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

    it "does not show the edit card button after answering" do
      follow_redirect!
      submit_demo_answer

      expect(rendered).to have_no_button("Edit card")
    end

    context "when reaching the milestone" do
      before do
        guest_deck = Deck.last
        follow_redirect!
        guest_deck.cards.first.update!(correct_streak: 0)
        create_list(:card, 49, deck: guest_deck, back: "A", correct_streak: 0)
        create(:card, deck: guest_deck)
        guest_deck.cards.reload.where(correct_streak: 0).find_each do |card|
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
      card = create(:card, deck:, back: "Paris", correct_streak: 0)
      create(:card, deck:)
      submit_answer(card:, answer: "Paris")

      expect(rendered).to have_content("1 / 50 completed")
    end

    context "when completed reaches milestone goal" do
      before do
        deck.update!(study_goal: 3)
        cards =
          3.times.map do
            create(:card, deck:, back: "Paris", correct_streak: 0)
          end
        create(:card, deck:)
        cards.each { |card| submit_answer(card:, answer: "Paris") }
      end

      it "shows milestone prompt", :aggregate_failures do
        expect(rendered).to have_content("You've completed 3 cards")
        expect(rendered).to have_link("Keep Going")
        expect(rendered).to have_link("Done for Now")
      end

      it "adds complete class to completed bar" do
        expect(rendered).to have_css(".session-progress-bar-complete")
      end
    end

    it "shows level complete screen when last card is answered" do
      card = create(:card, deck:, back: "Paris", correct_streak: 0)
      submit_answer(card:, answer: "Paris")

      expect(rendered).to have_css("h2", text: "Level 1 Complete!")
    end

    it "advances deck level when last card is completed" do
      card = create(:card, deck:, back: "Paris", correct_streak: 0)

      expect { submit_answer(card:, answer: "Paris") }
        .to change_record(deck, :level).from(1).to(2)
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
        create(:card, deck:)
        submit_answer(card:, answer: "Paris")

        expect(rendered).to have_css(".answer-correct", text: "Paris")
      end

      it "fades the other answers" do
        card = create(:card, deck:, back: "Paris")
        create(:card, deck:)
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
