# frozen_string_literal: true

module Demo
  module CleanupGuestUsers
    extend self

    def call
      User
        .where(role: "guest")
        .where(created_at: ...24.hours.ago)
        .find_each(&:destroy)
    end
  end
end
