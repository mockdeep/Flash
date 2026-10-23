# frozen_string_literal: true

# Opens the user's deck for another section of a deck's source, made on
# first pick.
class DeckSectionsController < ApplicationController
  def create
    deck = current_user.decks.find(params.expect(:deck_id))
    snippet = deck.snippets.studyable.find(params.expect(:snippet_id))
    section = current_user.reading_deck_over(deck.word_list, snippet:)
    redirect_to(deck_study_path(section))
  end
end
