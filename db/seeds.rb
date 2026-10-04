# frozen_string_literal: true

require_relative "seeds/admin"
require_relative "seeds/music_decks"

Seeds::MusicDecks.call(owner: Seeds::Admin.call)
