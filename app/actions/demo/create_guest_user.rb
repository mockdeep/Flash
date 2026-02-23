# frozen_string_literal: true

module Demo
  module CreateGuestUser
    class << self
      def call(deck:)
        guest = build_guest
        copy_deck_for(guest, deck)
      end

      private

      def build_guest
        id = SecureRandom.hex(8)
        User.new(
          role: "guest",
          username: "guest_#{id}",
          email: "guest_#{id}@localhost",
          password: SecureRandom.hex,
        )
      end

      def copy_deck_for(guest, deck)
        ActiveRecord::Base.transaction do
          guest.save!
          copy = Catalog::CopyDeck.call(user: guest, deck:)
          return Result.new(user: guest, deck: copy.record)
        end
      end
    end

    Result = Data.define(:user, :deck)
  end
end
