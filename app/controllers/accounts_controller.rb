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
    user = User.new(user_params)
    if user.save
      flash[:success] = "Account created successfully"
      log_in(user)
      redirect_to(root_path)
    else
      flash.now[:error] = "There was a problem setting up your account"
      render(Views::Accounts::New.new(user:))
    end
  end

  def update
    if current_user.update(user_params)
      flash[:success] = "Account updated successfully"
      redirect_to(root_path)
    else
      flash.now[:error] = "There was a problem updating your account"
      render(Views::Accounts::Show.new(user: current_user))
    end
  end

  def destroy
    current_user.destroy!
    log_out
    flash[:success] = "Account permanently deleted"
    redirect_to(root_path)
  end

  private

  def user_params
    params.expect(user: [:email, :password, :password_confirmation])
  end
end
