# frozen_string_literal: true

class AdminConstraint
  def matches?(request)
    User.find(request.session[:user_id]).admin?
  end
end
