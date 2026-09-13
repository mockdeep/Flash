# frozen_string_literal: true

# The compendium's studyable unit (docs/compendium.md, 4.2): one sense per
# meaning of an entry, selected into word_lists through memberships whose
# position keeps the list's gloss order, with teaching sentences alongside.
# Category sits on the membership because it is a property of the word in a
# list, not of the word: the same entry is filed differently by different
# lists.
class CreateSenses < ActiveRecord::Migration[8.1]
  def change
    create_senses
    create_sense_memberships
    create_sense_examples
  end

  private

  def create_senses
    create_table :senses do |t|
      t.references :entry, null: false, foreign_key: true, index: false
      t.string :gloss, null: false
      t.timestamps
      t.index [:entry_id, :gloss], unique: true
    end
  end

  def create_sense_memberships
    create_table :sense_memberships do |t|
      t.references :sense, **owned_by_sense
      t.references :word_list, null: false, foreign_key: { on_delete: :cascade }
      t.integer :position, null: false
      t.string :category
      t.timestamps
      t.index [:sense_id, :word_list_id], unique: true
    end
  end

  def create_sense_examples
    create_table :sense_examples do |t|
      t.references :sense, **owned_by_sense
      t.string :sentence, null: false
      t.string :translation
      t.timestamps
      t.index [:sense_id, :sentence], unique: true
    end
  end

  # The composite unique index that follows covers lookups by sense.
  def owned_by_sense
    { null: false, foreign_key: { on_delete: :cascade }, index: false }
  end
end
