# frozen_string_literal: true

class WelcomeController < ApplicationController
  skip_before_action(:authenticate_user)
  before_action(:redirect_if_logged_in)

  def index
    render(Views::Welcome::Index.new)
  end

  private

  def redirect_if_logged_in
    redirect_to(decks_path) if current_user.logged_in?
  end
end
