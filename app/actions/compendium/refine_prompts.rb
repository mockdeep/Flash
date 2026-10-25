# frozen_string_literal: true

module Compendium
  # The refiner's system prompts. Both steps see the same batch under the
  # same rules, the flagger to find problems and the confirmer to keep only
  # the suggestions that hold up. The language's lexicon adds how its
  # entries are stored (readings, articles), its own rules and the
  # categories its lists file words under, where it has them.
  module RefinePrompts
    BATCH = <<~TEXT
      The compendium is a dictionary that language learners study as
      flashcards. Each card is one sense: a headword (with its reading, and
      for a noun its article) and an English gloss. You are given a batch of
      entries grouped by headword. Each sense comes with the word lists that
      hold it (a list's name may give a level, such as HSK 3, and the sense
      has a category in each list), its example sentences, and up to five
      sentences from texts that use it, by id, with the indexes of the
      tokens that use it and the sentences either side. `use_count` says how
      many sentences use it in all. A cast note gives each source's narrator
      and characters, with their genders.
    TEXT

    PROBLEMS = <<~TEXT
      Problems:
      - merged: one sense covers two meanings a learner should study apart.
      - duplicate: two senses mean the same and should be one.
      - gloss: a gloss that is wrong, misleading or awkward.
      - reading: a wrong reading, or for a noun a wrong article.
      - traditional: a wrong traditional form.
      - category: a sense filed under the wrong category in a list.
      - wrong_pick: a token or list holds a sense that does not fit how it is
        used there, where another sense (or a new one) would.
    TEXT

    RULES = <<~TEXT
      Rules:
      - A sense is meant for its uses. A gloss narrowed to fit a list's level
        or a text's sentences is right, not too narrow. Do not merge senses
        or broaden a gloss because a dictionary would.
      - Any change must suit every use of the sense: every sentence and every
        list. If a better gloss fits only some uses, split: add a new sense,
        and repoint those tokens, or attach those lists, to it.
      - A gloss does not add gender, person or number the word does not
        carry ("said", not "she said"). Where the word does carry it, check
        it against the cast note.
      - Suggest only what clearly improves what a learner sees. Matters of
        style and near-equal wordings are not problems. Most entries need
        nothing.
      - A suggestion lists every edit it needs, so applying it leaves nothing
        pointing at the wrong sense. A sense to be removed must first lose
        its tokens and lists.
      - Store a word the way its language stores words: below, or else as
        the entries beside it are. Leave out a field the language does not
        use rather than give it an empty value.
      - Explain each suggestion in plain English for a reviewer who may not
        know the language: what is wrong, shown with a sentence where you
        can.
    TEXT

    EDITS = <<~TEXT
      Edits, each naming its `action`. A sense is named by its id, or by
      "new 0", "new 1"… for the senses this suggestion's `add` edits make, in
      order:
      - revise: `sense`, and whichever of `gloss`, `reading`, `article` and
        `traditional` change. A new reading or article moves the sense to
        the entry that has it.
      - add: `headword`, `reading` (none in a language without readings),
        `gloss`, `article` for a noun that takes one, and `traditional` in
        a language with traditional forms: a new sense.
      - remove: `sense`, once no token or list uses it.
      - attach: `sense`, `list_id` and `category`; detach: `sense` and
        `list_id`.
      - recategorize: `sense`, `list_id` and the new `category`.
      - repoint: `sentence_id`, `token` (its index) and `sense`.
    TEXT

    FLAG_TASK = <<~TEXT
      You review the compendium for problems. Suggest a fix for each problem
      you find, under the headword it belongs to, with its problem, its
      reason, sentences that show it, how confident you are, and its edits.
    TEXT

    CONFIRM_TASK = <<~TEXT
      You check suggested fixes to the compendium. Each suggestion comes with
      an id. Keep a suggestion only if its problem is real, its edits fix it,
      every edit is needed and correct, and every use of every sense it
      touches still fits after them. Otherwise drop it, and say why in one
      sentence. When in doubt, drop it: the entry will be reviewed again
      later.
    TEXT

    FLAG = [FLAG_TASK, BATCH, PROBLEMS, RULES, EDITS].join("\n").freeze
    CONFIRM = [CONFIRM_TASK, BATCH, PROBLEMS, RULES, EDITS].join("\n").freeze

    def self.flag(code) = with_language(FLAG, code)
    def self.confirm(code) = with_language(CONFIRM, code)

    def self.with_language(prompt, code)
      lexicon = Lexicon.for(code)

      [prompt, *storage(lexicon), lexicon.refine, categories(lexicon)]
        .compact.join("\n")
    end

    def self.storage(lexicon)
      [
        ("Readings: none; leave `reading` out." unless lexicon.readings),
        if lexicon.articles?
          "Articles: #{lexicon.articles.join(", ")}, in `article`, never in " \
            "the headword."
        end,
      ]
    end

    def self.categories(lexicon)
      categories = lexicon.categories
      "Categories: #{categories.join(", ")}." if categories.any?
    end
  end
end
