# frozen_string_literal: true

RSpec.describe Demo::CleanupGuestUsers do
  describe ".call" do
    it "destroys guest users older than 24 hours" do
      old_guest = create(:user, :guest, created_at: 25.hours.ago)

      expect { described_class.call }
        .to change { User.exists?(old_guest.id) }
        .to(false)
    end

    it "preserves guest users newer than 24 hours" do
      recent_guest = create(:user, :guest, created_at: 23.hours.ago)

      expect { described_class.call }
        .not_to(change { User.exists?(recent_guest.id) })
    end

    it "preserves regular users" do
      regular_user = create(:user, created_at: 25.hours.ago)

      expect { described_class.call }
        .not_to(change { User.exists?(regular_user.id) })
    end

    it "cascades to destroy guest user decks" do
      old_guest = create(:user, :guest, created_at: 25.hours.ago)
      create(:deck, user: old_guest)

      expect { described_class.call }.to change(Deck, :count).by(-1)
    end
  end
end
