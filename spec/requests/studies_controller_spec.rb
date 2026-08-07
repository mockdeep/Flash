# frozen_string_literal: true

RSpec.describe StudiesController do
  before { login_as(default_user) }

  def submit_answer(card:, answer:)
    patch(
      deck_study_path(card.deck),
      params: {
        answer: {
          card_id: card.id,
          answer:,
          possible_answers: ["Paris", "London", "Berlin", "Rome"],
        },
      },
    )
  end

  def complete_milestone_goal
    deck = create(:deck, study_goal: 3)
    cards = create_list(:basic_card, 3, deck:, back: "Paris", correct_streak: 0)
    create(:basic_card, deck:)
    cards.each { |card| submit_answer(card:, answer: "Paris") }
    deck
  end

  describe "#show" do
    it "renders the study page", :aggregate_failures do
      card = create(:basic_card)
      get(deck_study_path(card.deck))

      expect(rendered).to have_text("completed")
    end

    it "shows filled segments for completed levels" do
      deck = create(:deck, level: 3)
      create(:basic_card, deck:)
      get(deck_study_path(deck))

      expect(rendered).to have_css(".level-fill--done", count: 2)
    end

    it "does not show the demo banner" do
      card = create(:basic_card)
      get(deck_study_path(card.deck))

      expect(rendered).to have_no_css(".demo-banner")
    end

    it "wires the font controller on a Mandarin deck", :aggregate_failures do
      deck = create(:reading_deck)
      create(:reading_card, deck:, front: "他", back: "he; him")
      get(deck_study_path(deck))

      expect(rendered).to have_css(".study-frame[data-controller~='font']")
      expect(rendered).to have_css("[data-font='kai']", visible: :all)
    end

    it "omits the font controller on a deck without a language" do
      card = create(:basic_card)
      get(deck_study_path(card.deck))

      expect(rendered).to have_no_css(".study-frame[data-controller~='font']")
    end

    it "wires the wake-lock controller on the study frame" do
      card = create(:basic_card)
      get(deck_study_path(card.deck))

      expect(rendered).to have_css(".study-frame[data-controller~='wake-lock']")
    end

    it "embeds the deck's hanzi for font prewarming on full page loads" do
      deck = create(:reading_deck)
      create(:reading_card, deck:, front: "他", back: "he; him")
      get(deck_study_path(deck))

      expect(rendered).to have_css("[data-font-hanzi-value='他']")
    end

    it "omits the hanzi payload on turbo frame navigations" do
      deck = create(:reading_deck)
      create(:reading_card, deck:, front: "他", back: "he; him")
      get(deck_study_path(deck), headers: { "Turbo-Frame" => "study" })

      expect(rendered).to have_no_css("[data-font-hanzi-value]")
    end

    it "resets completed counter when visiting on a new day" do
      card = create(:basic_card, back: "Paris")
      submit_answer(card:, answer: "London")
      travel_to(1.day.from_now)
      get(deck_study_path(card.deck))

      expect(rendered).to have_text("0 / 50 completed")
    end

    context "when the UTC day changes but the user's local day does not" do
      before do
        default_user.update!(time_zone: "America/Los_Angeles")
        card = create(:basic_card, back: "Paris", correct_streak: 0)
        create(:basic_card, deck: card.deck)
        # Both instants fall on the same calendar day in Los Angeles.
        travel_to(Time.utc(2026, 5, 29, 23)) do
          submit_answer(card:, answer: "Paris")
        end
        travel_to(Time.utc(2026, 5, 30, 5)) do
          get(deck_study_path(card.deck))
        end
      end

      it "does not reset the completed counter" do
        expect(rendered).to have_text("1 / 50 completed")
      end
    end

    context "when the user's local day changes" do
      before do
        default_user.update!(time_zone: "America/Los_Angeles")
        card = create(:basic_card, back: "Paris", correct_streak: 0)
        create(:basic_card, deck: card.deck)
        # The second instant crosses midnight in Los Angeles.
        travel_to(Time.utc(2026, 5, 30, 5)) do
          submit_answer(card:, answer: "Paris")
        end
        travel_to(Time.utc(2026, 5, 30, 8)) do
          get(deck_study_path(card.deck))
        end
      end

      it "resets the completed counter at local midnight" do
        expect(rendered).to have_text("0 / 50 completed")
      end
    end

    it "resets completed counter when reset_session param is present" do
      card = create(:basic_card, back: "Paris", correct_streak: 0)
      create(:basic_card, deck: card.deck)
      submit_answer(card:, answer: "Paris")
      get(deck_study_path(card.deck, reset_session: true))

      expect(rendered).to have_text("0 / 50 completed")
    end

    context "when returning after reaching milestone" do
      it "shows milestone heading" do
        get(deck_study_path(complete_milestone_goal))

        expect(rendered).to have_text("You've completed 3 cards")
      end

      it "shows keep going link" do
        get(deck_study_path(complete_milestone_goal))

        expect(rendered).to have_link("Keep Going")
      end

      it "shows done for now link" do
        get(deck_study_path(complete_milestone_goal))

        expect(rendered).to have_link("Done for Now")
      end
    end

    it "prevents viewing another user's deck" do
      other_deck = create(:deck, user: create(:user))

      get(deck_study_path(other_deck))

      expect(response).to have_http_status(:not_found)
    end

    it "shows empty deck message when no cards to study" do
      get(deck_study_path(create(:deck)))

      expect(rendered).to have_css("h2", text: "No cards to study")
    end
  end

  describe "demo mode" do
    def start_demo
      deck = create(:deck, user: create(:user), visibility: "public")
      create(:basic_card, deck:, front: "Q", back: "A")
      post(demo_path, params: { deck_id: deck.id, time_zone: "UTC" })
    end

    def submit_demo_answer(deck: Deck.last)
      card = deck.cards.first
      answers = ["A", "B", "C", "D"]
      params = {
        answer: {
          card_id: card.id,
          answer: "wrong",
          possible_answers: answers,
        },
      }
      patch(deck_study_path(deck), params:)
    end

    it "shows demo banner on the study page" do
      start_demo
      follow_redirect!

      expect(rendered).to have_css(".demo-banner")
    end

    it "does not show demo banner after answering" do
      start_demo
      follow_redirect!
      submit_demo_answer

      expect(rendered).to have_no_css(".demo-banner")
    end

    it "does not show the edit card button after answering" do
      start_demo
      follow_redirect!
      submit_demo_answer

      expect(rendered).to have_no_button("Edit card")
    end

    context "when reaching the milestone" do
      def answer_all_pending(deck)
        deck.cards.reload.where(correct_streak: 0).find_each do |card|
          params = {
            answer: {
              card_id: card.id,
              answer: "A",
              possible_answers: ["A", "B", "C", "D"],
            },
          }
          patch(deck_study_path(deck), params:)
        end
      end

      def reach_demo_milestone
        guest_deck = Deck.last
        follow_redirect!
        guest_deck.update!(study_goal: 3)
        guest_deck.cards.first.update!(correct_streak: 0)
        create_list(:basic_card, 2, deck: guest_deck, back: "A")
        create(:basic_card, deck: guest_deck)
        answer_all_pending(guest_deck)
        get(deck_study_path(guest_deck))
      end

      it "shows sign up link" do
        start_demo
        reach_demo_milestone

        expect(rendered).to have_link("Sign Up Free")
      end

      it "does not show done for now link" do
        start_demo
        reach_demo_milestone

        expect(rendered).to have_no_link("Done for Now")
      end
    end
  end

  describe "#update" do
    it "increments completed counter when card becomes done" do
      card = create(:basic_card, back: "Paris", correct_streak: 0)
      create(:basic_card, deck: card.deck)
      submit_answer(card:, answer: "Paris")

      expect(rendered).to have_text("1 / 50 completed")
    end

    context "when completed reaches milestone goal" do
      it "does not show the milestone prompt" do
        complete_milestone_goal

        expect(rendered).to have_no_text("You've completed 3 cards")
      end

      it "shows the next card link" do
        complete_milestone_goal

        expect(rendered).to have_link("Next Card")
      end

      it "adds complete class to completed bar" do
        complete_milestone_goal

        expect(rendered).to have_css(".session-progress-bar-complete")
      end

      it "shows milestone prompt after pressing next" do
        get(deck_study_path(complete_milestone_goal))

        expect(rendered).to have_text("You've completed 3 cards")
      end
    end

    it "stamps the deck's last studied time" do
      card = create(:basic_card, back: "Paris")
      create(:basic_card, deck: card.deck)

      expect { submit_answer(card:, answer: "Paris") }
        .to change_record(card.deck, :last_studied_at).from(nil)
    end

    it "stamps the deck's last studied time on an incorrect answer" do
      card = create(:basic_card, back: "Paris")
      create(:basic_card, deck: card.deck)

      expect { submit_answer(card:, answer: "London") }
        .to change_record(card.deck, :last_studied_at).from(nil)
    end

    it "shows level complete screen when last card is answered" do
      card = create(:basic_card, back: "Paris", correct_streak: 0)
      submit_answer(card:, answer: "Paris")

      expect(rendered).to have_css("h2", text: "Level 1 Complete!")
    end

    it "shows the earned segment on the level complete screen" do
      card = create(:basic_card, back: "Paris", correct_streak: 0)
      submit_answer(card:, answer: "Paris")

      expect(rendered).to have_css(".level-fill--done", count: 1)
    end

    it "advances deck level when last card is completed" do
      deck = create(:deck)
      card = create(:basic_card, deck:, back: "Paris", correct_streak: 0)

      expect { submit_answer(card:, answer: "Paris") }
        .to change_record(deck, :level).from(1).to(2)
    end

    context "when answer is correct" do
      it "increments correct count" do
        card = create(:basic_card, back: "Paris", correct_count: 0)

        expect { submit_answer(card:, answer: "Paris") }
          .to change_record(card, :correct_count).from(0).to(1)
      end

      it "increments correct streak" do
        card = create(:basic_card, back: "Paris", correct_streak: 0)

        expect { submit_answer(card:, answer: "Paris") }
          .to change_record(card, :correct_streak).from(0).to(1)
      end

      it "highlights the correct answer" do
        card = create(:basic_card, back: "Paris")
        create(:basic_card, deck: card.deck)
        submit_answer(card:, answer: "Paris")

        expect(rendered).to have_css(".answer-correct", text: "Paris")
      end

      it "fades the other answers" do
        card = create(:basic_card, back: "Paris")
        create(:basic_card, deck: card.deck)
        submit_answer(card:, answer: "Paris")

        expect(rendered).to have_css(".answer-faded", text: "London")
      end

      it "does not show streak pips at level 1" do
        card = create(:basic_card, back: "Paris", correct_streak: 0)
        create(:basic_card, deck: card.deck)
        submit_answer(card:, answer: "Paris")

        expect(rendered).to have_no_css(".answer-streak")
      end

      it "shows streak progress at level 2" do
        deck = create(:deck, level: 2)
        card = create(:basic_card, deck:, back: "Paris", correct_streak: 0)
        create(:basic_card, deck:)
        submit_answer(card:, answer: "Paris")

        expect(rendered).to have_css(".answer-streak", text: "1/2")
      end

      it "fills one pip per correct answer in a row" do
        deck = create(:deck, level: 2)
        card = create(:basic_card, deck:, back: "Paris", correct_streak: 0)
        create(:basic_card, deck:)
        submit_answer(card:, answer: "Paris")

        expect(rendered).to have_css(".streak-pip--filled", count: 1)
      end

      it "shows all pips filled when the card clears" do
        deck = create(:deck, level: 2)
        card = create(:basic_card, deck:, back: "Paris", correct_streak: 1)
        create(:basic_card, deck:, correct_streak: 0)
        submit_answer(card:, answer: "Paris")

        expect(rendered).to have_css(".streak-pip--filled", count: 2)
      end
    end

    context "when answer is incorrect" do
      it "resets correct streak" do
        card = create(:basic_card, back: "Paris", correct_streak: 5)

        expect { submit_answer(card:, answer: "London") }
          .to change_record(card, :correct_streak).to(0)
      end

      it "adds wrong answer to card" do
        card = create(:basic_card, back: "Paris")

        expect { submit_answer(card:, answer: "London") }
          .to change { card.reload.distractors }
          .from([]).to(["London"])
      end

      it "marks the wrong answer" do
        card = create(:basic_card, back: "Paris")
        submit_answer(card:, answer: "London")

        expect(rendered).to have_css(".answer-incorrect", text: "London")
      end

      it "reveals the correct answer" do
        card = create(:basic_card, back: "Paris")
        submit_answer(card:, answer: "London")

        expect(rendered).to have_css(".answer-correct", text: "Paris")
      end

      it "does not show streak pips" do
        deck = create(:deck, level: 2)
        card = create(:basic_card, deck:, back: "Paris")
        submit_answer(card:, answer: "London")

        expect(rendered).to have_no_css(".answer-streak")
      end

      it "shows the next card link" do
        card = create(:basic_card, back: "Paris")
        create(:basic_card, deck: card.deck)
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
    def music_deck(**attrs)
      create(:music_deck, ordered: true, **attrs)
    end

    def submit_music_window(deck, answer:)
      window = MusicStudy.new(deck: deck.reload).next_window
      patch(
        deck_study_path(deck),
        params: { answer: { card_ids: window.map(&:id), answer: } },
      )
    end

    def seed_notes(deck, notes)
      notes.each { |n| create(:music_card, deck:, back: n) }
    end

    it "renders the mic-driven study UI on #show" do
      deck = music_deck
      create(:music_card, deck:, back: "C4")

      get(deck_study_path(deck))

      expect(rendered).to have_css("[data-controller='music-study']")
    end

    it "wires the wake-lock controller on the study frame" do
      deck = music_deck
      create(:music_card, deck:, back: "C4")

      get(deck_study_path(deck))

      expect(rendered).to have_css("turbo-frame[data-controller~='wake-lock']")
    end

    it "exposes the joined card window to Stimulus on #show" do
      deck = music_deck(level: 3)
      seed_notes(deck, ["C4", "E4", "G4"])
      get(deck_study_path(deck))

      expect(rendered)
        .to have_css("[data-music-study-sequence-value='C4,E4,G4']")
    end

    it "stamps the deck's last studied time" do
      deck = music_deck
      seed_notes(deck, ["C4", "E4"])

      expect { submit_music_window(deck, answer: "C4") }
        .to change_record(deck, :last_studied_at).from(nil)
    end

    it "renders the music-result UI after a correct answer" do
      deck = music_deck
      seed_notes(deck, ["C4", "E4"])

      submit_music_window(deck, answer: "C4")

      expect(rendered).to have_css(".music-study--result")
    end

    it "marks the outcome as correct after a correct answer" do
      deck = music_deck
      seed_notes(deck, ["C4", "E4"])

      submit_music_window(deck, answer: "C4")

      expect(rendered).to have_css(".music-study__outcome--correct")
    end

    it "shows the empty-state message when the deck has no cards" do
      get(deck_study_path(music_deck))

      expect(rendered).to have_css("h2", text: "No cards to study")
    end

    it "shows the milestone prompt when completed reaches the goal" do
      deck = music_deck(study_goal: 1)
      seed_notes(deck, ["C4", "E4"])
      submit_music_window(deck, answer: "C4")
      get(deck_study_path(deck))

      expect(rendered).to have_text("You've completed 1 cards")
    end

    it "shows the level-complete UI when the last card is answered" do
      deck = music_deck
      create(:music_card, deck:, back: "C4")

      submit_music_window(deck, answer: "C4")

      expect(rendered).to have_css("h2", text: "Level 1 Complete!")
    end

    it "links to the next level from the level-complete UI" do
      deck = music_deck
      create(:music_card, deck:, back: "C4")

      submit_music_window(deck, answer: "C4")

      expect(rendered).to have_link("Continue to Level 2")
    end

    it "marks the outcome as incorrect after a wrong answer" do
      deck = music_deck
      seed_notes(deck, ["C4", "E4"])

      submit_music_window(deck, answer: "D4")

      expect(rendered).to have_css(".music-study__outcome--incorrect")
    end

    it "shows the demo banner in demo mode" do
      deck = create(:music_deck, user: create(:user), visibility: "public")
      create(:music_card, deck:, back: "C4")
      post(demo_path, params: { deck_id: deck.id, time_zone: "UTC" })
      follow_redirect!

      expect(rendered).to have_css(".demo-banner")
    end

    it "still renders the multiple-choice UI for non-music decks" do
      card = create(:basic_card)

      get(deck_study_path(card.deck))

      expect(rendered).to have_css(".study-answers-grid")
    end
  end

  describe "reading stage" do
    def reading_card(**attrs)
      deck = create(:deck, level: 2)
      create(:basic_card, deck:, reading: "liǎng", **attrs)
    end

    def submit_reading(card:, answer:)
      answer_params = {
        card_id: card.id,
        answer:,
        stage: "reading",
        possible_answers: ["liǎng", "sān"],
      }
      patch(deck_study_path(card.deck), params: { answer: answer_params })
    end

    it "asks for the reading first at level 2" do
      card = reading_card
      get(deck_study_path(card.deck))

      expect(rendered).to have_text("Pick the reading")
    end

    it "offers the reading as an answer option" do
      card = reading_card
      get(deck_study_path(card.deck))

      expect(rendered).to have_css(".answer-button", text: "liǎng")
    end

    it "skips the gate when the card has no reading" do
      card = reading_card(reading: nil)
      get(deck_study_path(card.deck))

      expect(rendered).to have_no_text("Pick the reading")
    end

    context "when the reading is answered correctly" do
      it "renders the translation question for the same card" do
        card = reading_card(front: "两", back: "two")
        submit_reading(card:, answer: "liǎng")

        expect(rendered).to have_css(".card-front", text: "两")
      end

      it "offers the translation as an answer option" do
        card = reading_card(back: "two")
        submit_reading(card:, answer: "liǎng")

        expect(rendered).to have_css(".answer-button", text: "two")
      end

      it "shows the confirmed reading under the character" do
        card = reading_card(back: "two")
        submit_reading(card:, answer: "liǎng")

        expect(rendered).to have_css("#card-reading", text: "liǎng")
      end

      it "no longer asks for the reading" do
        card = reading_card(back: "two")
        submit_reading(card:, answer: "liǎng")

        expect(rendered).to have_no_text("Pick the reading")
      end

      it "does not change the correct streak" do
        card = reading_card(correct_streak: 1)

        expect { submit_reading(card:, answer: "liǎng") }
          .to not_change_record(card, :correct_streak)
      end
    end

    context "when the reading is answered incorrectly" do
      it "reveals the correct reading" do
        card = reading_card
        submit_reading(card:, answer: "sān")

        expect(rendered).to have_css(".answer-correct", text: "liǎng")
      end

      it "marks the wrong reading" do
        card = reading_card
        submit_reading(card:, answer: "sān")

        expect(rendered).to have_css(".answer-incorrect", text: "sān")
      end

      it "resets the correct streak" do
        card = reading_card(correct_streak: 1)

        expect { submit_reading(card:, answer: "sān") }
          .to change_record(card, :correct_streak).from(1).to(0)
      end

      it "does not record the wrong reading as a distractor" do
        card = reading_card

        expect { submit_reading(card:, answer: "sān") }
          .to(not_change { card.reload.distractors })
      end

      it "shows the next card link" do
        card = reading_card
        submit_reading(card:, answer: "sān")

        expect(rendered).to have_link("Next Card")
      end
    end
  end

  describe "reading" do
    it "renders the card reading after answering" do
      card = create(:basic_card, back: "two", reading: "liǎng")
      submit_answer(card:, answer: "wrong")

      expect(rendered).to have_css("#card-reading", text: "liǎng")
    end

    it "does not render a reading before answering" do
      card = create(:basic_card, reading: "liǎng")
      get(deck_study_path(card.deck))

      expect(rendered).to have_no_css("#card-reading")
    end
  end

  context "when not authenticated" do
    it "redirects #show to sign in" do
      delete(session_path)
      get(deck_study_path(create(:deck)))

      expect(response).to redirect_to(new_session_path)
    end

    it "redirects #update to sign in" do
      delete(session_path)
      patch(deck_study_path(create(:deck)), params: { answer: {} })

      expect(response).to redirect_to(new_session_path)
    end
  end
end
