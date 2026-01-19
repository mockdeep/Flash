# frozen_string_literal: true

RSpec.describe User do
  def user_params
    {
      email: "demo@exampoo.com",
      password: "super-secure",
      password_confirmation: "super-secure",
    }
  end

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to have_secure_password }
  it { is_expected.to normalize(:email).from(" FO@bOOn.GL ").to("fo@boon.gl") }

  it do
    create(:user)

    expect(described_class.new)
      .to validate_uniqueness_of(:email).case_insensitive
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

  describe ".find_by" do
    it "returns a user record when it exists" do
      user = described_class.create!(user_params)

      expect(described_class.find_by(email: user.email)).to eq(user)
    end

    it "returns a null user when a user does not exist" do
      expect(described_class.find_by(email: "boo@email")).to be_a(NullUser)
    end
  end

  describe ".find" do
    context "when id is present" do
      it "returns the user when found" do
        user = described_class.create!(user_params)

        expect(described_class.find(user.id)).to eq(user)
      end

      it "raises an error when user is not found" do
        expect { described_class.find(5) }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    it "returns a null user when id is not present" do
      expect(described_class.find(nil)).to be_a(NullUser)
    end
  end

  describe "#logged_in?" do
    it "returns true" do
      expect(described_class.new.logged_in?).to be(true)
    end
  end

  describe "#admin?" do
    it "returns false" do
      expect(described_class.new.admin?).to be(false)
    end
  end
end
