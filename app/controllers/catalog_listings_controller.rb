# frozen_string_literal: true

class CatalogListingsController < ApplicationController
  before_action(:require_admin)

  def create
    owned_deck.update!(visibility: "public")
    flash[:success] = t(".success")
    redirect_to(deck_path(owned_deck))
  end

  def destroy
    owned_deck.update!(visibility: "private")
    flash[:success] = t(".success")
    redirect_to(deck_path(owned_deck))
  end

  private

  def require_admin
    head(:not_found) unless current_user.admin?
  end

  def owned_deck
    @owned_deck ||= current_user.decks.find(params.expect(:deck_id))
  end
end
