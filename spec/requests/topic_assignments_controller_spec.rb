# frozen_string_literal: true

RSpec.describe TopicAssignmentsController do
  describe "#create" do
    def post_assignment(deck, name: "Mandarin")
      post(deck_topic_assignment_path(deck), params: { topic: { name: } })
    end

    it "requires authentication" do
      post_assignment(create(:deck))

      expect(response).to redirect_to(new_session_path)
    end

    it "creates the topic on first use" do
      deck = create(:deck, user: default_user)
      login_as(default_user)

      expect { post_assignment(deck) }.to change(Topic, :count).by(1)
    end

    it "assigns the deck's data_set to the topic" do
      deck = create(:deck, user: default_user)
      login_as(default_user)

      post_assignment(deck, name: "Mandarin")

      expect(deck.data_set.reload.topic.name).to eq("Mandarin")
    end

    it "reuses an existing topic with the same name" do
      create(:topic, name: "Mandarin", user: default_user)
      deck = create(:deck, user: default_user)
      login_as(default_user)

      expect { post_assignment(deck, name: "Mandarin") }
        .not_to change(Topic, :count)
    end

    it "redirects back to the deck" do
      deck = create(:deck, user: default_user)
      login_as(default_user)

      post_assignment(deck)

      expect(response).to redirect_to(deck_path(deck))
    end

    it "sets a success flash naming the topic" do
      deck = create(:deck, user: default_user)
      login_as(default_user)

      post_assignment(deck, name: "Mandarin")

      expect(flash[:success]).to eq("Added to the Mandarin topic")
    end

    it "rejects a blank topic name" do
      deck = create(:deck, user: default_user)
      login_as(default_user)

      post_assignment(deck, name: "  ")

      expect(flash[:error]).to eq("Topic name can't be blank")
    end

    it "does not create a topic for a blank name" do
      deck = create(:deck, user: default_user)
      login_as(default_user)

      expect { post_assignment(deck, name: "  ") }.not_to change(Topic, :count)
    end

    it "returns not found for another user's deck" do
      login_as(default_user)

      post_assignment(create(:deck, user: create(:user)))

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "#destroy" do
    it "releases the data_set from its topic" do
      deck = create(:deck, user: default_user)
      deck.data_set.update!(topic: create(:topic, user: default_user))
      login_as(default_user)

      delete(deck_topic_assignment_path(deck))

      expect(deck.data_set.reload.topic).to be_nil
    end

    it "sets a success flash" do
      deck = create(:deck, user: default_user)
      deck.data_set.update!(topic: create(:topic, user: default_user))
      login_as(default_user)

      delete(deck_topic_assignment_path(deck))

      expect(flash[:success]).to eq("Removed from topic")
    end

    it "redirects back to the deck" do
      deck = create(:deck, user: default_user)
      login_as(default_user)

      delete(deck_topic_assignment_path(deck))

      expect(response).to redirect_to(deck_path(deck))
    end
  end
end
