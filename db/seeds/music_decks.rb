# frozen_string_literal: true

module Seeds
  module MusicDecks
    DECKS = [
      {
        name: "Open Ukulele Strings",
        cards: [
          { front: "G string (4th)", back: "G4" },
          { front: "C string (3rd)", back: "C4" },
          { front: "E string (2nd)", back: "E4" },
          { front: "A string (1st)", back: "A4" },
        ],
      },
      {
        name: "Guitar E String, Frets 0–5",
        cards: [
          { front: "Open E", back: "E2" },
          { front: "1st fret (F)", back: "F2" },
          { front: "2nd fret (F♯)", back: "F#2" },
          { front: "3rd fret (G)", back: "G2" },
          { front: "4th fret (G♯)", back: "G#2" },
          { front: "5th fret (A)", back: "A2" },
        ],
      },
    ].freeze

    def self.call
      owner = User.where(role: "admin").first || User.first
      unless owner
        warn("[seeds] no users found; skipping music deck seeds")
        return
      end

      DECKS.each { |attrs| seed_deck(owner, attrs) }
    end

    def self.seed_deck(owner, attrs)
      deck = find_or_create_deck(owner, attrs[:name])
      attrs[:cards].each { |card_attrs| seed_card(deck, card_attrs) }
    end

    def self.find_or_create_deck(owner, name)
      MusicDeck.find_or_create_by!(name:, user: owner) do |d|
        d.visibility = "public"
        d.study_goal = owner.study_goal
      end
    end

    def self.seed_card(deck, attrs)
      MusicCard.find_or_create_by!(deck:, front: attrs[:front]) do |c|
        c.back = attrs[:back]
        c.category = "Notes"
      end
    end
  end
end
