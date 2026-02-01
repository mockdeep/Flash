# frozen_string_literal: true

RSpec.describe Deck do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to have_many(:cards).dependent(:delete_all) }

  it do
    create(:deck)

    expect(described_class.new)
      .to validate_uniqueness_of(:name).scoped_to(:user_id)
  end

  describe "dependent: :delete_all" do
    it "deletes all cards when deck is destroyed" do
      deck = create(:deck)
      card1 = create(:card, deck:)
      card2 = create(:card, deck:)

      expect { deck.destroy! }
        .to change(Card, :count).by(-2)
    end

    it "does not affect cards from other decks" do
      deck1 = create(:deck)
      deck2 = create(:deck)
      create(:card, deck: deck1)
      create(:card, deck: deck2)

      expect { deck1.destroy! }
        .to change(Card, :count).by(-1)
    end
  end
end
