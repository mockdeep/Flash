# frozen_string_literal: true

class AdminConstraint
  def matches?(request)
    User.find_by(id: request.session[:user_id]).admin?
  end
end
