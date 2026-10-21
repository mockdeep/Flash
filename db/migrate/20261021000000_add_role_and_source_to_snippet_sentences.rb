# frozen_string_literal: true

# A sentence says what it is (a source's title or author, a snippet's heading,
# or a line of its body), and a source's title and author belong to the
# source rather than to any snippet. Positions run on within a snippet, so the
# unique constraint waits for the end of the transaction: a push that shifts
# them would otherwise trip over a position still held by the row it moves to.
class AddRoleAndSourceToSnippetSentences < ActiveRecord::Migration[8.1]
  def change
    add_column(:snippet_sentences, :role, :string, null: false, default: "body")
    add_reference(
      :snippet_sentences, :source, foreign_key: { on_delete: :cascade }
    )

    reversible { |dir| dir.up { backfill } }

    change_column_null(:snippet_sentences, :source_id, false)
    change_column_null(:snippet_sentences, :snippet_id, true)
    safety_assured { constrain }
  end

  private

  def backfill
    safety_assured do
      execute(<<~SQL.squish)
        UPDATE snippet_sentences
        SET source_id = snippets.source_id
        FROM snippets
        WHERE snippets.id = snippet_sentences.snippet_id
      SQL
    end
  end

  def constrain
    remove_index(:snippet_sentences, [:snippet_id, :position], unique: true)
    add_unique_constraint(
      :snippet_sentences,
      [:snippet_id, :position],
      deferrable: :deferred,
      name: "snippet_sentences_snippet_id_position",
    )
    add_index(
      :snippet_sentences,
      [:source_id, :position],
      unique: true,
      where: "snippet_id IS NULL",
    )
    add_check_constraint(
      :snippet_sentences,
      "(snippet_id IS NULL) = (role IN ('title', 'author'))",
      name: "snippet_sentences_front_matter",
    )
  end
end
