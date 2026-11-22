# frozen_string_literal: true

class ReadingMapsController < ApplicationController
  before_action(:require_admin)

  def show
    chart = ReadingMap::Chart.new(user: current_user, language:)

    render(Views::ReadingMaps::Show.new(chart:))
  end

  private

  # The language whose name the address gives ("mandarin"), among those
  # with word lists.
  def language
    section = params.expect(:section)
    languages = WordList.distinct.pluck(:language)

    languages.find { WordList::LANGUAGES[it].parameterize == section } ||
      raise(ActiveRecord::RecordNotFound)
  end
end
