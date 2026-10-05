# frozen_string_literal: true

# Studies a snippet's word_list: finds or makes the user's reading deck over
# it. From the deck's page an admin can publish it to the catalog, where
# others add the list by reference like any language deck.
class SnippetDecksController < ApplicationController
  before_action(:require_admin)

  def create
    snippet = current_user.snippets.find(params.expect(:snippet_id))
    deck = current_user.decks.create_with(deck_defaults)
      .find_or_create_by!(type: "ReadingDeck", word_list: snippet.word_list)

    redirect_to(deck_path(deck))
  end

  private

  def deck_defaults
    { distractor_pool: "category", study_goal: current_user.study_goal }
  end
end
