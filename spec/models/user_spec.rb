# frozen_string_literal: true

RSpec.describe User do
  def user_params
    {
      role: "user",
      username: "demo_user",
      email: "demo@exampoo.com",
      password: "super-secure",
      password_confirmation: "super-secure",
      time_zone: "UTC",
    }
  end

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:username) }
  it { is_expected.to have_secure_password }
  it { is_expected.to normalize(:email).from(" FO@bOOn.GL ").to("fo@boon.gl") }
  it { is_expected.to normalize(:username).from(" spacey ").to("spacey") }

  it { is_expected.to allow_value("America/New_York").for(:time_zone) }
  it { is_expected.not_to allow_value("Not/AZone").for(:time_zone) }
  it { is_expected.not_to allow_value("").for(:time_zone) }
  it { is_expected.not_to allow_value(nil).for(:time_zone) }

  it do
    create(:user)

    expect(described_class.new)
      .to validate_uniqueness_of(:email).case_insensitive
  end

  it do
    create(:user)

    expect(described_class.new).to validate_uniqueness_of(:username)
  end

  it "allows good emails" do
    good_emails = [
      "b@b.com", "mrspicy+extra@yepyep.com", "you.are@atthe.museum"
    ]

    expect(described_class.new).to allow_values(*good_emails).for(:email)
  end

  it "does not allow bad emails" do
    bad_emails = ["b#b.com", "mrspicy>extra@yepyep.com", "blahbloo"]

    expect(described_class.new).not_to allow_values(bad_emails).for(:email)
  end

  it "allows valid usernames" do
    good_usernames = ["alice", "bob_smith", "User123", "test.user"]

    expect(described_class.new).to allow_values(*good_usernames).for(:username)
  end

  it "does not allow invalid usernames" do
    bad_usernames = ["has space", "no@sign", "no-dashes", "no!bang"]

    expect(described_class.new)
      .not_to allow_values(*bad_usernames).for(:username)
  end

  it "validates role inclusion" do
    expect(described_class.new)
      .to validate_inclusion_of(:role).in_array(User::ROLES)
  end

  describe ".find_by" do
    it "returns a user record when it exists" do
      user = described_class.create!(user_params)

      expect(described_class.find_by(email: user.email)).to eq(user)
    end

    it "returns a null user when a user does not exist" do
      expect(described_class.find_by(email: "boo@email")).to be_a(NullUser)
    end
  end

  describe ".find_by!" do
    it "returns a user record when it exists" do
      user = described_class.create!(user_params)

      expect(described_class.find_by!(email: user.email)).to eq(user)
    end

    it "raises RecordNotFound when user does not exist" do
      expect { described_class.find_by!(email: "missing@email.com") }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#logged_in?" do
    it "returns true" do
      expect(described_class.new.logged_in?).to be(true)
    end
  end

  describe "#admin?" do
    it "returns false for regular users" do
      expect(described_class.new.admin?).to be(false)
    end

    it "returns true for admin users" do
      expect(described_class.new(role: "admin").admin?).to be(true)
    end
  end

  describe "#guest?" do
    it "returns false for regular users" do
      expect(described_class.new.guest?).to be(false)
    end

    it "returns true for guest users" do
      expect(described_class.new(role: "guest").guest?).to be(true)
    end
  end

  describe "#study_goal" do
    it "defaults to 50" do
      expect(described_class.new.study_goal).to eq(50)
    end

    it "validates numericality" do
      expect(described_class.new)
        .to validate_numericality_of(:study_goal)
        .only_integer
        .is_greater_than_or_equal_to(1)
    end
  end

  describe "guest users" do
    it "is valid with generated email and username" do
      guest = build(:user, :guest)

      expect(guest).to be_valid
    end
  end

  describe "#supporter?" do
    it "returns false when the user has no subscription" do
      user = create(:user)

      expect(user.supporter?).to be(false)
    end

    it "returns true when the user has an active subscription" do
      user = create(:user)
      create(:subscription, user:)

      expect(user.supporter?).to be(true)
    end

    it "returns false when the user's subscription is canceled" do
      user = create(:user)
      create(:subscription, :canceled, user:)

      expect(user.supporter?).to be(false)
    end

    it "returns false when the user's subscription is past_due" do
      user = create(:user)
      create(:subscription, :past_due, user:)

      expect(user.supporter?).to be(false)
    end
  end

  describe "#pending_incoming_suggestions?" do
    def seed_pending_suggestion(user:, **overrides)
      deck = create(:deck, user:)
      card = create(:basic_card, deck:)
      create(:card_suggestion, card:, **overrides)
    end

    it "returns true when one of the user's cards has a pending suggestion" do
      user = create(:user)
      seed_pending_suggestion(user:)

      expect(user.pending_incoming_suggestions?).to be(true)
    end

    it "returns false when the user has no decks" do
      user = create(:user)

      expect(user.pending_incoming_suggestions?).to be(false)
    end

    it "returns false when the user's suggestions are all resolved" do
      user = create(:user)
      seed_pending_suggestion(user:, state: "accepted")

      expect(user.pending_incoming_suggestions?).to be(false)
    end

    it "ignores suggestions on other users' decks" do
      user = create(:user)
      seed_pending_suggestion(user: create(:user))

      expect(user.pending_incoming_suggestions?).to be(false)
    end
  end

  describe "#pending_suggestion_counts_per_deck" do
    def seed_pending_suggestion(deck:, **overrides)
      card = create(:basic_card, deck:)
      create(:card_suggestion, card:, **overrides)
    end

    it "returns counts keyed by deck id" do
      user = create(:user)
      deck = create(:deck, user:)
      seed_pending_suggestion(deck:)
      seed_pending_suggestion(deck:)

      expect(user.pending_suggestion_counts_per_deck).to eq(deck.id => 2)
    end

    it "omits decks with no pending suggestions" do
      user = create(:user)
      create(:deck, user:)

      expect(user.pending_suggestion_counts_per_deck).to be_empty
    end

    it "ignores accepted suggestions" do
      user = create(:user)
      deck = create(:deck, user:)
      seed_pending_suggestion(deck:, state: "accepted")

      expect(user.pending_suggestion_counts_per_deck).to be_empty
    end
  end
end
