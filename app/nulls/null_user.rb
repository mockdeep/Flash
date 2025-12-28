# frozen_string_literal: true

class NullUser
  def authenticate(_password)
    false
  end

  def logged_in?
    false
  end

  def admin?
    false
  end
end
