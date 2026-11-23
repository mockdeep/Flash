# frozen_string_literal: true

# Starts a list from the reading map: finds or makes the user's deck for a
# source's first section, or for the whole of a list with no source, and
# opens its study page.
class WordListDecksController < ApplicationController
  def create
    lists = WordList.visible_to(current_user)
    word_list = lists.find(params.expect(:word_list_id))
    source = word_list.source
    deck = source ? current_user.deck_starting(source) : whole(word_list)

    redirect_to(deck_study_path(deck))
  end

  private

  def whole(word_list) = current_user.reading_deck_over(word_list, snippet: nil)
end
