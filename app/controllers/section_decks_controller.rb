# frozen_string_literal: true

# A section's page at /<section>/decks: a language's reading map
# (/mandarin/decks), or the user's own Basic or Music decks. The section
# viewed is remembered on the user.
class SectionDecksController < ApplicationController
  def show
    sections = DeckSection.open_to(current_user)
    section = sections.find { it.anchor == params.expect(:section) } ||
      raise(ActiveRecord::RecordNotFound)
    current_user.update!(decks_section: section.anchor)

    render(view_for(section).new(section:, sections:))
  end

  private

  def view_for(section)
    section.language ? Views::SectionDecks::Map : Views::SectionDecks::Rail
  end
end
