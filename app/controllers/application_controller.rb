# frozen_string_literal: true

require "action_controller"

class ApplicationController < ActionController::Base
  layout false

  before_action(:authenticate_user)

  private

  def log_in(user)
    cleanup_demo_guest unless user.guest?
    session[:user_id] = user.id
    @current_user = user
  end

  def log_out
    session.clear
    @current_user = NullUser.new
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
  helper_method :current_user

  def authenticate_user
    return if current_user.logged_in? && !current_user.guest?

    redirect_to(new_session_path)
  end

  def authenticate_guest
    redirect_to(new_session_path) unless current_user.logged_in?
  end

  def cleanup_demo_guest
    guest_id = session.delete(:demo_user_id)
    session.delete(:demo)
    User.find_by(id: guest_id).destroy! if guest_id
  end
end
