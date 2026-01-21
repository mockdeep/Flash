# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action(:authenticate_user)

  def pricing
    render(Views::Pages::Pricing.new)
  end

  def privacy
    render(Views::Pages::Privacy.new)
  end

  def terms
    render(Views::Pages::Terms.new)
  end
end
