# frozen_string_literal: true

module DemoSession
  extend ActiveSupport::Concern

  private

  def save_demo_session(result)
    log_in(result.user)
    session[:demo_user_id] = result.user.id
    session[:demo] = true
  end
end
