# frozen_string_literal: true

module Demo
  module CreateGuestUser
    class << self
      # A source starts the guest at its first section.
      def call(time_zone:, deck: nil, source: nil)
        guest = build_guest(time_zone)

        ActiveRecord::Base.transaction do
          guest.save!
          Result.new(user: guest, deck: deck_for(guest, deck:, source:))
        end
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

      def deck_for(guest, deck:, source:)
        return guest.deck_starting(source) if source

        Catalog::CopyDeck.call(user: guest, deck:).record
      end
    end

    Result = Data.define(:user, :deck)
  end
end
