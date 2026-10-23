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
  it { is_expected.to have_many(:decks).dependent(:destroy) }
  it { is_expected.to have_many(:word_lists).dependent(:destroy) }
  it { is_expected.to have_many(:sources).through(:word_lists) }
  it { is_expected.to have_many(:sense_distractors).dependent(:delete_all) }
  it { is_expected.to have_many(:skill_scores).dependent(:delete_all) }
  it { is_expected.to have_many(:source_readers).dependent(:delete_all) }

  it "destroys its own decks before its word_lists" do
    deck = create(:reading_deck)

    expect { deck.user.destroy! }.to change(WordList, :count).by(-1)
  end

  it "cannot be destroyed while another user's deck references its list" do
    deck = create(:reading_deck)
    create(:reading_deck, user: create(:user), word_list: deck.word_list)

    expect { deck.user.destroy! }
      .to raise_error(ActiveRecord::DeleteRestrictionError)
  end

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

  describe "#next_unmet_deck" do
    def met_goal_deck(**)
      deck = create(:deck, study_goal: 1, **)
      deck.study_days.create!(studied_on: Date.current, completed_count: 1)
      deck
    end

    it "returns the first deck in decks-page order that is under its goal" do
      create(:deck, name: "Alpha")
      deck = create(:reading_deck, name: "Zebra")

      expect(default_user.next_unmet_deck).to eq(deck)
    end

    it "skips decks that met their goal today" do
      met_goal_deck(name: "Alpha")
      deck = create(:deck, name: "Zebra")

      expect(default_user.next_unmet_deck).to eq(deck)
    end

    it "skips music decks" do
      create(:music_deck, name: "Alpha")
      deck = create(:deck, name: "Zebra")

      expect(default_user.next_unmet_deck).to eq(deck)
    end

    it "returns nil when every deck met its goal" do
      met_goal_deck

      expect(default_user.next_unmet_deck).to be_nil
    end
  end

  describe "#reading_deck_over" do
    it "creates a reading deck over the list" do
      user = create(:user)
      word_list = create(:word_list)

      expect(user.reading_deck_over(word_list))
        .to have_attributes(type: "ReadingDeck", word_list:)
    end

    it "starts the deck at the user's study goal" do
      user = create(:user, study_goal: 20)

      expect(user.reading_deck_over(create(:word_list)).study_goal).to eq(20)
    end

    it "reuses the deck the user already has over the list" do
      deck = create(:reading_deck)

      expect(deck.user.reading_deck_over(deck.word_list)).to eq(deck)
    end

    it "creates a deck for a snippet of the list" do
      user = create(:user)
      snippet = create(:snippet)

      expect(user.reading_deck_over(snippet.word_list, snippet:))
        .to have_attributes(snippet:)
    end

    it "keeps a snippet's deck apart from the whole list's" do
      snippet = create(:snippet)
      deck = create(:reading_deck, word_list: snippet.word_list, snippet:)

      expect(deck.user.reading_deck_over(deck.word_list)).not_to eq(deck)
    end
  end

  describe "#deck_starting" do
    it "makes the user's deck for the source's first section" do
      snippet = create(:snippet, :finished)
      user = create(:user)

      expect(user.deck_starting(snippet.source).snippet).to eq(snippet)
    end

    it "reuses the deck the user already has for it" do
      snippet = create(:snippet, :finished)
      deck = default_user.deck_starting(snippet.source)

      expect(default_user.deck_starting(snippet.source)).to eq(deck)
    end
  end

  describe "#deck_for" do
    it "returns the deck itself when the user owns it" do
      deck = create(:deck)

      expect(deck.user.deck_for(deck)).to eq(deck)
    end

    it "returns the user's copy of a flat deck" do
      source = create(:deck, user: create(:user))
      copy = create(:deck, source_deck: source)

      expect(copy.user.deck_for(source)).to eq(copy)
    end

    it "ignores another user's copy of a flat deck" do
      source = create(:deck, user: create(:user))
      create(:deck, source_deck: source)

      expect(create(:user).deck_for(source)).to be_nil
    end

    it "returns the user's deck over a language deck's word_list" do
      source = create(:reading_deck, user: create(:user))
      own_deck = create(:reading_deck, word_list: source.word_list)

      expect(own_deck.user.deck_for(source)).to eq(own_deck)
    end

    it "returns nil when the user has no matching deck" do
      expect(create(:user).deck_for(create(:reading_deck))).to be_nil
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
end
