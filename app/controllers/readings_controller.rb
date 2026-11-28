# frozen_string_literal: true

# A page of a deck's text on the Read tab, turned to inside its frame, which
# becomes where the reader left off. Outside the frame it is the study page.
class ReadingsController < ApplicationController
  skip_before_action(:authenticate_user)
  before_action(:authenticate_guest)

  def show
    deck = current_user.decks.find(params.expect(:deck_id))
    return redirect_to(deck_study_path(deck)) unless turbo_frame_request?

    pages = ReadingPages.for(deck)
    page = turn_to(pages, deck)
    render(Views::Readings::Show.new(deck:, pages:, page:))
  end

  private

  def turn_to(pages, deck)
    raise ActiveRecord::RecordNotFound if pages.none?

    page = pages.at(params[:sentence], params[:token])
    ReadingPlace.record!(
      user: current_user,
      source: deck.source,
      start: page.start,
    )
    page
  end
end
