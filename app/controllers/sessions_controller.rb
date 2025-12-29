# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action(:authenticate_user, only: [:new, :create])

  def new
    render(Views::Sessions::New.new)
  end

  def create
    user = User.find_by(email: session_params[:email])
    if user.authenticate(session_params[:password])
      log_in(user)
      redirect_to(root_path)
    else
      flash.now[:error] = "Invalid email or password"
      render(Views::Sessions::New.new)
    end
  end

  def destroy
    log_out
    redirect_to(root_path)
  end

  private

  def session_params
    params.expect(session: [:email, :password])
  end
end
