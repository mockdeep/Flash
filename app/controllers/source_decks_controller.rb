# frozen_string_literal: true

# Studies a source: finds or makes the user's deck for its first section,
# from which the section picker reaches the rest.
class SourceDecksController < ApplicationController
  before_action(:require_admin)

  def create
    source = current_user.sources.find(params.expect(:source_id))
    deck = current_user.deck_starting(source)

    redirect_to(deck_study_path(deck))
  end
end
