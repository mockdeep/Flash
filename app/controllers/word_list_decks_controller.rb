# frozen_string_literal: true

# Starts a list from the reading map: finds or makes the user's deck over it
# and opens its study page.
class WordListDecksController < ApplicationController
  def create
    lists = WordList.visible_to(current_user)
    word_list = lists.find(params.expect(:word_list_id))
    deck = current_user.reading_deck_over(word_list)

    redirect_to(deck_study_path(deck))
  end
end
