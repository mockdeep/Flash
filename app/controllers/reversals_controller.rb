# frozen_string_literal: true

class ReversalsController < ApplicationController
  def create
    result = Decks::CreateReverse.call(source: deck)
    if result.success?
      flash[:success] = t(".success")
      redirect_to(deck_path(result.record))
    else
      flash[:error] = t(".error")
      redirect_to(deck_path(deck))
    end
  end

  private

  def deck
    @deck ||= current_user.decks.find(params.expect(:deck_id))
  end
end
