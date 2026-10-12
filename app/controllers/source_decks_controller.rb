# frozen_string_literal: true

# Studies a source's word_list: finds or makes the user's reading deck over
# it. From the deck's page an admin can publish it to the catalog, where
# others add the list by reference like any language deck.
class SourceDecksController < ApplicationController
  before_action(:require_admin)

  def create
    source = current_user.sources.find(params.expect(:source_id))
    deck = current_user.reading_deck_over(source.word_list)

    redirect_to(deck_study_path(deck))
  end
end
