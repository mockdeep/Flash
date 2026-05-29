# frozen_string_literal: true

module Demo
  module CreateGuestUser
    CARD_LIMIT = 100

    class << self
      def call(deck:, time_zone:)
        guest = build_guest(time_zone)
        copy_deck_for(guest, deck)
      end

      private

      def build_guest(time_zone)
        id = SecureRandom.hex(8)
        User.new(
          role: "guest",
          username: "guest_#{id}",
          email: "guest_#{id}@localhost",
          password: SecureRandom.hex,
          time_zone:,
        )
      end

      def copy_deck_for(guest, deck)
        ActiveRecord::Base.transaction do
          guest.save!
          copy = Catalog::CopyDeck.call(
            user: guest, deck:, card_limit: CARD_LIMIT,
          )
          return Result.new(user: guest, deck: copy.record)
        end
      end
    end

    Result = Data.define(:user, :deck)
  end
end
