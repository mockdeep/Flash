# frozen_string_literal: true

class NullUser
  def username = nil

  def time_zone = "UTC"

  def authenticate(_password)
    false
  end

  def presence; end

  def logged_in?
    false
  end

  def admin?
    false
  end

  def guest?
    false
  end

  def supporter?
    false
  end

  def destroy!; end
end
