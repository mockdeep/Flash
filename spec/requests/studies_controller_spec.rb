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

      expect(rendered).to have_text("completed")
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

    it "wires the font controller on a Mandarin deck", :aggregate_failures do
      deck = create(:deck, language: "zh")
      create(:card, deck:, front: "他", back: "he; him")
      get(deck_study_path(deck))

      expect(rendered).to have_css(".study-frame[data-controller~='font']")
      expect(rendered).to have_css("[data-font='kai']", visible: :all)
    end

    it "omits the font controller on a deck without a language" do
      create(:card, deck:)
      get(deck_study_path(deck))

      expect(rendered).to have_no_css(".study-frame[data-controller~='font']")
    end

    it "embeds the deck's hanzi for font prewarming on full page loads" do
      deck = create(:deck, language: "zh")
      create(:card, deck:, front: "他", back: "he; him")
      get(deck_study_path(deck))

      expect(rendered).to have_css("[data-font-hanzi-value='他']")
    end

    it "omits the hanzi payload on turbo frame navigations" do
      deck = create(:deck, language: "zh")
      create(:card, deck:, front: "他", back: "he; him")
      get(deck_study_path(deck), headers: { "Turbo-Frame" => "study" })

      expect(rendered).to have_no_css("[data-font-hanzi-value]")
    end

    context "when visiting on a new day" do
      before do
        card = create(:card, deck:, back: "Paris")
        submit_answer(card:, answer: "London")
        travel_to(1.day.from_now)
        get(deck_study_path(deck))
      end

      it "resets completed counter" do
        expect(rendered).to have_text("0 / 50 completed")
      end
    end

    context "when the UTC day changes but the user's local day does not" do
      before do
        default_user.update!(time_zone: "America/Los_Angeles")
        card = create(:card, deck:, back: "Paris", correct_streak: 0)
        create(:card, deck:)
        # Both instants fall on the same calendar day in Los Angeles.
        travel_to(Time.utc(2026, 5, 29, 23)) do
          submit_answer(card:, answer: "Paris")
        end
        travel_to(Time.utc(2026, 5, 30, 5)) { get(deck_study_path(deck)) }
      end

      it "does not reset the completed counter" do
        expect(rendered).to have_text("1 / 50 completed")
      end
    end

    context "when the user's local day changes" do
      before do
        default_user.update!(time_zone: "America/Los_Angeles")
        card = create(:card, deck:, back: "Paris", correct_streak: 0)
        create(:card, deck:)
        # The second instant crosses midnight in Los Angeles.
        travel_to(Time.utc(2026, 5, 30, 5)) do
          submit_answer(card:, answer: "Paris")
        end
        travel_to(Time.utc(2026, 5, 30, 8)) { get(deck_study_path(deck)) }
      end

      it "resets the completed counter at local midnight" do
        expect(rendered).to have_text("0 / 50 completed")
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
        expect(rendered).to have_text("0 / 50 completed")
      end
    end

    context "when returning after reaching milestone" do
      before do
        deck.update!(study_goal: 3)
        cards =
          3.times.map do
            create(:card, deck:, back: "Paris", correct_streak: 0)
          end
        create(:card, deck:)
        cards.each { |card| submit_answer(card:, answer: "Paris") }
        get(deck_study_path(deck))
      end

      it "shows milestone heading" do
        expect(rendered).to have_text("You've completed 3 cards")
      end

      it "shows keep going link" do
        expect(rendered).to have_link("Keep Going")
      end

      it "shows done for now link" do
        expect(rendered).to have_link("Done for Now")
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
    let(:demo_deck) { create(:deck, user: demo_owner, visibility: "public") }

    before do
      create(:card, deck: demo_deck, front: "Q", back: "A")
      post(demo_path, params: { deck_id: demo_deck.id, time_zone: "UTC" })
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
        guest_deck.update!(study_goal: 3)
        guest_deck.cards.first.update!(correct_streak: 0)
        create_list(:card, 2, deck: guest_deck, back: "A", correct_streak: 0)
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
        get(deck_study_path(guest_deck))
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

      expect(rendered).to have_text("1 / 50 completed")
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

      it "does not show the milestone prompt" do
        expect(rendered).to have_no_text("You've completed 3 cards")
      end

      it "shows the next card link" do
        expect(rendered).to have_link("Next Card")
      end

      it "adds complete class to completed bar" do
        expect(rendered).to have_css(".session-progress-bar-complete")
      end

      it "shows milestone prompt after pressing next" do
        get(deck_study_path(deck))

        expect(rendered).to have_text("You've completed 3 cards")
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

      it "does not show streak pips at level 1" do
        card = create(:card, deck:, back: "Paris", correct_streak: 0)
        create(:card, deck:)
        submit_answer(card:, answer: "Paris")

        expect(rendered).to have_no_css(".answer-streak")
      end

      it "shows streak progress at level 2" do
        deck.update!(level: 2)
        card = create(:card, deck:, back: "Paris", correct_streak: 0)
        create(:card, deck:)
        submit_answer(card:, answer: "Paris")

        expect(rendered).to have_css(".answer-streak", text: "1/2")
      end

      it "fills one pip per correct answer in a row" do
        deck.update!(level: 2)
        card = create(:card, deck:, back: "Paris", correct_streak: 0)
        create(:card, deck:)
        submit_answer(card:, answer: "Paris")

        expect(rendered).to have_css(".streak-pip--filled", count: 1)
      end

      it "shows all pips filled when the card clears" do
        deck.update!(level: 2)
        card = create(:card, deck:, back: "Paris", correct_streak: 1)
        create(:card, deck:, correct_streak: 0)
        submit_answer(card:, answer: "Paris")

        expect(rendered).to have_css(".streak-pip--filled", count: 2)
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
          .to change { card.reload.distractors }
          .from([]).to(["London"])
      end

      it "marks the wrong answer" do
        card = create(:card, deck:, back: "Paris")
        submit_answer(card:, answer: "London")

        expect(rendered).to have_css(".answer-incorrect", text: "London")
      end

      it "reveals the correct answer" do
        card = create(:card, deck:, back: "Paris")
        submit_answer(card:, answer: "London")

        expect(rendered).to have_css(".answer-correct", text: "Paris")
      end

      it "does not show streak pips" do
        deck.update!(level: 2)
        card = create(:card, deck:, back: "Paris")
        submit_answer(card:, answer: "London")

        expect(rendered).to have_no_css(".answer-streak")
      end

      it "shows the next card link" do
        card = create(:card, deck:, back: "Paris")
        create(:card, deck:)
        submit_answer(card:, answer: "London")

        expect(rendered).to have_link("Next Card")
      end
    end

    it "prevents updating another user's deck" do
      other_deck = create(:deck, user: create(:user))

      patch(deck_study_path(other_deck), params: { answer: {} })

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "for a music deck" do
    let(:music_deck) { create(:music_deck, ordered: true) }

    def submit_music_window(answer:)
      window = MusicStudy.new(deck: music_deck.reload).next_window
      patch(
        deck_study_path(music_deck),
        params: { answer: { card_ids: window.map(&:id), answer: } },
      )
    end

    it "renders the mic-driven study UI on #show" do
      create(:music_card, deck: music_deck, back: "C4")

      get(deck_study_path(music_deck))

      expect(rendered).to have_css("[data-controller='music-study']")
    end

    it "exposes the joined card window to Stimulus on #show" do
      music_deck.update!(level: 3)
      seed_notes(music_deck, ["C4", "E4", "G4"])
      get(deck_study_path(music_deck))

      expect(rendered)
        .to have_css("[data-music-study-sequence-value='C4,E4,G4']")
    end

    def seed_notes(deck, notes)
      notes.each { |n| create(:music_card, deck:, back: n) }
    end

    it "renders the music-result UI after a correct answer" do
      create(:music_card, deck: music_deck, back: "C4")
      create(:music_card, deck: music_deck, back: "E4")

      submit_music_window(answer: "C4")

      expect(rendered).to have_css(".music-study--result")
    end

    it "marks the outcome as correct after a correct answer" do
      create(:music_card, deck: music_deck, back: "C4")
      create(:music_card, deck: music_deck, back: "E4")

      submit_music_window(answer: "C4")

      expect(rendered).to have_css(".music-study__outcome--correct")
    end

    it "shows the empty-state message when the deck has no cards" do
      get(deck_study_path(music_deck))

      expect(rendered).to have_css("h2", text: "No cards to study")
    end

    context "when completed reaches the milestone goal" do
      before do
        music_deck.update!(study_goal: 1)
        create(:music_card, deck: music_deck, back: "C4")
        create(:music_card, deck: music_deck, back: "E4")
        submit_music_window(answer: "C4")
        get(deck_study_path(music_deck))
      end

      it "shows the milestone prompt" do
        expect(rendered).to have_text("You've completed 1 cards")
      end
    end

    it "shows the level-complete UI when the last card is answered" do
      create(:music_card, deck: music_deck, back: "C4")

      submit_music_window(answer: "C4")

      expect(rendered).to have_css("h2", text: "Level 1 Complete!")
    end

    it "links to the next level from the level-complete UI" do
      create(:music_card, deck: music_deck, back: "C4")

      submit_music_window(answer: "C4")

      expect(rendered).to have_link("Continue to Level 2")
    end

    it "marks the outcome as incorrect after a wrong answer" do
      create(:music_card, deck: music_deck, back: "C4")
      create(:music_card, deck: music_deck, back: "E4")

      submit_music_window(answer: "D4")

      expect(rendered).to have_css(".music-study__outcome--incorrect")
    end

    context "when in demo mode" do
      let(:demo_owner) { create(:user) }
      let(:demo_music_deck) do
        create(:music_deck, user: demo_owner, visibility: "public")
      end

      before do
        create(:music_card, deck: demo_music_deck, back: "C4")
        post(
          demo_path,
          params: { deck_id: demo_music_deck.id, time_zone: "UTC" },
        )
        follow_redirect!
      end

      it "shows the demo banner" do
        expect(rendered).to have_css(".demo-banner")
      end
    end

    it "still renders the multiple-choice UI for non-music decks" do
      create(:card, deck:)

      get(deck_study_path(deck))

      expect(rendered).to have_css(".study-answers-grid")
    end
  end

  describe "reading" do
    it "renders the card reading after answering" do
      card = create(:card, deck:, back: "two", reading: "liǎng")
      submit_answer(card:, answer: "wrong")

      expect(rendered).to have_css("#card-reading", text: "liǎng")
    end

    it "does not render a reading before answering" do
      create(:card, deck:, reading: "liǎng")
      get(deck_study_path(deck))

      expect(rendered).to have_no_css("#card-reading")
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
