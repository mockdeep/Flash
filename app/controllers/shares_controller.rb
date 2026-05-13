# frozen_string_literal: true

class SharesController < ApplicationController
  include DemoSession

  skip_before_action(:authenticate_user, only: [:show, :try])

  def show
    render(Views::Shares::Show.new(deck: shared_deck))
  end

  def copy
    result = Catalog::CopyDeck.call(user: current_user, deck: shared_deck)
    result.success? ? deck_copied : deck_copy_failed(result.record)
  end

  def try
    result = Demo::CreateGuestUser.call(deck: shared_deck)
    save_demo_session(result)
    redirect_to(deck_study_path(result.deck))
  end

  def create
    owned_deck.generate_share_token!
    flash[:success] = t(".success")
    redirect_to(deck_path(owned_deck))
  end

  def destroy
    owned_deck.revoke_share_token!
    flash[:success] = t(".success")
    redirect_to(deck_path(owned_deck))
  end

  private

  def deck_copied
    flash[:success] = t(".success")
    redirect_to(decks_path)
  end

  def deck_copy_failed(record)
    flash.now[:error] = error_messages(record)
    render(Views::Shares::Show.new(deck: shared_deck))
  end

  def shared_deck
    Deck.find_by!(share_token: params.expect(:token))
  end

  def owned_deck
    @owned_deck ||= current_user.decks.find(params.expect(:deck_id))
  end

  def error_messages(record)
    record.errors.full_messages.join(", ")
  end
end
