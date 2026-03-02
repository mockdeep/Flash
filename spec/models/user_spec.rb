# frozen_string_literal: true

RSpec.describe User do
  def user_params
    {
      role: "user",
      username: "demo_user",
      email: "demo@exampoo.com",
      password: "super-secure",
      password_confirmation: "super-secure",
    }
  end

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:username) }
  it { is_expected.to have_secure_password }
  it { is_expected.to normalize(:email).from(" FO@bOOn.GL ").to("fo@boon.gl") }
  it { is_expected.to normalize(:username).from(" spacey ").to("spacey") }

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

  describe "guest users" do
    it "is valid with generated email and username" do
      guest = build(:user, :guest)

      expect(guest).to be_valid
    end
  end
end
