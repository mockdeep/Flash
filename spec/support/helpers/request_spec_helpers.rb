# frozen_string_literal: true

module Helpers
  module RequestSpecHelpers
    def login_as(user)
      params = { session: { email: user.email, password: user.password } }
      post(session_path, params:)
    end
  end
end

RSpec.configure do |config|
  config.include(Helpers::RequestSpecHelpers, type: :request)
end
