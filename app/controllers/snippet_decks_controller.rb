# frozen_string_literal: true

# Studies a snippet's word_list: finds or makes the user's reading deck over
# it. From the deck's page an admin can publish it to the catalog, where
# others add the list by reference like any language deck.
class SnippetDecksController < ApplicationController
  before_action(:require_admin)

  def create
    snippet = current_user.snippets.find(params.expect(:snippet_id))
    deck = current_user.reading_deck_over(snippet.word_list)

    redirect_to(deck_study_path(deck))
  end
end
