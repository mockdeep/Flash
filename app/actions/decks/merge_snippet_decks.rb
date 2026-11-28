# frozen_string_literal: true

module Decks
  # One-off: folds each user's decks over a source, one per snippet (and any
  # over the whole source made since), into one over the whole source. The
  # most recently studied is kept, with its goal settings and study days;
  # the rest go, giving it their share link and catalog listing if it has
  # none. Its round starts over, for the study page to catch up to the
  # user's progress, which lives on the words. Returns a line per deck kept.
  # Delete once its production run is verified.
  module MergeSnippetDecks
    NEVER = Time.zone.at(0)

    def self.call = groups.map { merge(it) }

    def self.groups
      ReadingDeck.where(word_list_id: Source.select(:word_list_id))
        .order(:id).group_by { [it.user_id, it.word_list_id] }.values
        .select { |decks| decks.any?(&:snippet_id) }
    end

    def self.merge(decks)
      kept = decks.max_by { [it.last_studied_at || NEVER, it.id] }
      others = decks - [kept]
      Deck.transaction do
        others.each(&:destroy!)
        kept.update!(snippet: nil, round: 1, **carried(kept, others))
      end

      "#{kept.user.username} · #{kept.name}: kept deck #{kept.id}, " \
        "removed #{others.size}"
    end

    def self.carried(kept, others)
      public = [kept, *others].any?(&:publicly_visible?)
      {
        share_token: kept.share_token || others.filter_map(&:share_token).first,
        visibility: public ? "public" : kept.visibility,
      }
    end
  end
end
