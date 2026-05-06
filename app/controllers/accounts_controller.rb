# frozen_string_literal: true

require_relative "application_controller"

class AccountsController < ApplicationController
  skip_before_action(:authenticate_user, only: [:new, :create])

  def show
    render(Views::Accounts::Show.new(user: current_user))
  end

  def new
    render(Views::Accounts::New.new(user: User.new))
  end

  def create
    user = User.new(user_params.merge(role: "user"))
    if user.save
      flash[:success] = t(".success")
      log_in(user)
      redirect_to(root_path)
    else
      flash.now[:error] = t(".error")
      render(Views::Accounts::New.new(user:))
    end
  end

  def update
    if current_user.update(user_params)
      flash[:success] = t(".success")
      redirect_to(root_path)
    else
      flash.now[:error] = t(".error")
      render(Views::Accounts::Show.new(user: current_user))
    end
  end

  def destroy
    current_user.destroy!
    log_out
    flash[:success] = t(".success")
    redirect_to(root_path)
  end

  private

  def user_params
    params.expect(
      user: [
        :username,
        :email,
        :password,
        :password_confirmation,
        :study_goal,
      ],
    )
  end
end
