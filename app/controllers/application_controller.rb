# frozen_string_literal: true

require "action_controller"

class ApplicationController < ActionController::Base
  layout false

  before_action(:authenticate_user)

  private

  def log_in(user)
    session[:user_id] = user.id
    @current_user = user
  end

  def log_out
    session.clear
    @current_user = NullUser.new
  end

  def current_user
    @current_user ||= User.find(session[:user_id])
  end
  helper_method :current_user

  def authenticate_user
    redirect_to(new_session_path) unless current_user.logged_in?
  end
end
