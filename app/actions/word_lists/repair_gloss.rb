# frozen_string_literal: true

module WordLists
  # A one-off owed by phase 4's fork-collapse pre-rung (docs/compendium.md):
  # two Portuguese glosses came out of the catalog wrong ("a cor de laranja"
  # as "the orange", "a gente" as "the people"). Nothing loads the catalog
  # into the app any more, so the fix is made here, ahead of 4.2 so the
  # senses import already corrected.
  #
  # The pairing is retargeted rather than the Back item edited in place: Back
  # items are shared within a list (the fruit "a laranja" pairs to the same
  # "the orange"), so editing the text would change every front that uses it.
  # The old Back item stays even when nothing pairs to it any more; unpaired
  # backs are ordinary, since misses create them as decoys.
  #
  #   list = WordList.find_by!(name: "Portuguese (Brazilian) A1")
  #   WordLists::RepairGloss.call(
  #     word_list: list, front: "a gente", from: "the people", to: %w[we us],
  #   )                    # writes nothing
  #   WordLists::RepairGloss.call(..., dry_run: false)
  module RepairGloss
    extend self

    Report = Data.define(:front, :from, :to, :shared_with)

    def call(word_list:, front:, from:, to:, dry_run: true)
      prompt = word_list.items.find_by!(side: Projection::FRONT, text: front)
      old = word_list.items.find_by!(side: Projection::BACK, text: from)
      pairing = prompt.pairings.find_by!(paired_item: old)
      ActiveRecord::Base.transaction do
        retarget(pairing, backs(word_list, to))
        raise ActiveRecord::Rollback if dry_run
      end
      Report.new(front:, from:, to:, shared_with: shared_with(old, prompt))
    end

    private

    # The first new gloss takes over the existing pairing, keeping its place
    # in the front's gloss order; any further glosses append after it.
    def retarget(pairing, backs)
      first, *rest = backs
      pairing.update!(paired_item: first)
      rest.each do |back|
        Pairing.create!(item: pairing.item, paired_item: back)
      end
    end

    def backs(word_list, texts)
      texts.map do |text|
        word_list.items.find_or_create_by!(side: Projection::BACK, text:)
      end
    end

    # Other fronts the old Back item still glosses, so the report shows what
    # was shared and left alone.
    def shared_with(old, prompt)
      sharers = Pairing.where(paired_item: old).where.not(item: prompt)
      Item.where(id: sharers.select(:item_id)).order(:id).pluck(:text)
    end
  end
end
