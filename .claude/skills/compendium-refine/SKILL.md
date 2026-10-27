---
name: compendium-refine
description: Work through the overnight compendium refiner's suggestions with the user in Flash — table the simple fixes for bulk approval, walk the bigger ones one at a time, apply what the user accepts, and hand off to pushing. Also starts a refiner run. Use when the user wants to run the refiner, go through its suggestions, or asks what it found.
---

# Compendium refine

`bin/rails compendium:refine` reviews compendium entries through Claude, longest
unreviewed first, and writes the fixes Opus confirmed to
`tmp/compendium_refine/<language>-<entry id>.json`, one file per headword. Your
job is to put those suggestions to the user, apply the ones they accept, and
drop the rest. Nothing is applied without their say-so. AGENTS.md ("Compendium
Refiner", "Compendium Review") has the details; the `compendium-review` skill
has the edits and pushing.

## Running the refiner

`bin/rails compendium:refine` runs until the usage limit stops it (the last
line says "Stopped: …") or every entry has been reviewed. It prints a line per
batch of about twenty entries. Run it in the background. `LIMIT=<n>` stops it
after n entries, for a short run.

## Working with the user

- **The user may not know the language.** Each suggestion says what is wrong
  in plain English; pass that on, with the word, its reading where it has one,
  the current gloss and the proposed one. Add a sentence that shows the
  problem where the suggestion gives one.
- **Check bigger suggestions against a reference** before putting them
  forward, as in `compendium-review` (CC-CEDICT or Wiktionary for Mandarin;
  Wiktionary, Priberam or Michaelis for Portuguese; Wiktionary or tagalog.com for Filipino; Wiktionary for others).
  Say when a reference disagrees with the suggestion.
- Keep it brief: tables for the bulk pass, a few lines per suggestion after.

## A session

1. **Stale files.** `bin/rails runner 'puts Compendium::Suggestions.stale'`
   lists files whose entries have changed since they were written, so their
   suggestions may no longer fit. Tell the user how many, and on their
   go-ahead delete them; the entries come round again in a later run.
2. **Read the files** in `tmp/compendium_refine/`. Each has the `language`,
   `headword` and `entry_ids`, and its `suggestions`, each with a `problem`,
   `reason`, `examples`, `confidence`, `edits` and `confirmed` (Opus's reason
   for keeping it). Look up anything unclear with `bin/rails
   compendium:lookup Q=<headword>` (`IN=<code>` for a language other than
   Mandarin).
3. **Simple fixes in bulk**: `category`, `traditional` and `reading`
   suggestions. Show them in one table (headword, problem, current → proposed,
   confidence) and ask the user to accept all or name the ones to skip.
   Apply the accepted ones and dismiss the skipped.
4. **The rest one at a time** (`gloss`, `merged`, `duplicate`,
   `wrong_pick`), high confidence first, a headword at a time. For each, say
   what is wrong, what the edits would do in plain words (not the raw edit
   list), and wait for one of:
   - **yes**: apply it.
   - **no**: dismiss it. If the user's reason would apply to many entries
     ("glosses shouldn't name the subject"), offer to add it as a rule to
     `app/actions/compendium/refine_prompts.rb`. That is a code change, so
     propose the wording and wait.
   - **change it**: work out the amended edits, show them, and apply those
     instead.
5. **Push.** When the user is done, follow `compendium-review`'s Pushing
   section. The refiner's `reviewed_at` marks travel too, so a push follows
   every run even when no suggestion was accepted.

## Applying

Every call runs through `bin/rails runner`. A suggestion is named by its file
and its index in that file's `suggestions`.

```ruby
path = "tmp/compendium_refine/zh-123.json"
Compendium::Suggestions.apply(path, 0)                  # run its edits
Compendium::Suggestions.dismiss(path, 0)                # drop it
Compendium::Suggestions.apply(path, 0, edits: [         # run amended edits
  { action: "revise", sense: "456", gloss: "flower" },
])
```

- Applying or dismissing takes the suggestion out of its file, so the indexes
  after it shift down by one. Read the file again before the next call. A file
  goes when its last suggestion does.
- A suggestion's edits run together or not at all. When one fails, read the
  error back to the user. `Edit::Refused` means a sense still in use cannot be
  removed; `Suggestions::Stale` means the file's entries changed since it was
  written.
- Edits name senses by id, or `"new 0"`, `"new 1"`… for the senses the
  suggestion's own `add` edits make. Actions and their fields:
  - `revise`: `sense`, with any of `gloss`, `reading`, `article`, `traditional`
  - `add`: `headword`, `reading`, `gloss`, `article`, `traditional`
  - `remove`: `sense`
  - `attach`: `sense`, `list_id`, `category`; `detach`: `sense`, `list_id`
  - `recategorize`: `sense`, `list_id`, `category`
  - `repoint`: `sentence_id`, `token` (its index), `sense`. The snippet is
    finished again afterwards, which adds the new sense to its list and
    categorizes it through Claude.
