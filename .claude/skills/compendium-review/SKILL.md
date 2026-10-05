---
name: compendium-review
description: Review Chinese vocabulary in Flash's compendium with the user — walk a processed snippet (unresolved words, new senses, wrong picks), look into and fix any word or sense, finish a snippet, and push the results to production. Use when the user wants to process, review or finish a snippet, check or fix a gloss, reading or sense, split a merged sense, or push compendium changes.
---

# Compendium review

The compendium (entries, senses, word lists, snippets) is edited **locally** and
copied to production by `compendium:push`; production never edits it. Your job
in a review is to find what is wrong, explain it, propose fixes, and apply only
what the user agrees to. AGENTS.md ("Snippet Processing", "Compendium Review",
"Compendium Sync") has the details behind every command here.

## Working with the user

- **The user does not read Mandarin.** Explain every finding in English: the
  word, its pinyin, the gloss, and why it is wrong or right *in this sentence*.
- **Back each judgment with a reference**, not your own say-so: CC-CEDICT (look
  the word up on mdbg.net), Wiktionary, or another dictionary you can cite.
  Where references disagree or the call is a policy question, say so and let
  the user decide.
- **Judge against the card rules** in `app/actions/snippets/policy.rb`
  (segmentation, readings, function words). Read it at the start of a review.
- **Propose fixes in batches and wait for approval** before running any edit.
  Reading commands (`snippets:review`, `compendium:lookup`) need no approval.
- Keep it brief: a short table of findings beats paragraphs.

## Before a session

1. The local database should match production. If unsure, run
   `bin/rails compendium:pull` (the user must stop the dev server and jobs
   worker first). It refuses while local work is unpushed; never pass
   `FORCE=true` without the user saying so, since it discards that work.
2. Snippets are added in the app (`/snippets`, admin only), locally or in
   production. One added in production arrives with the next pull.

## Processing

`bin/rails snippets:process` segments and resolves every unprocessed sentence
through the Claude CLI, printing a line per batch. It takes a while on a long
text, so run it in the background and report when it finishes. Lines starting
"Re-segmented" name a sentence sent back to the segmenter and why.

## Reviewing a snippet

1. `bin/rails snippets:review ID=<id>` (no `ID`: every unfinished snippet).
   The report gives sentence ids, token indexes and sense ids (`#123`), which
   every edit takes.
2. Work through it in this order:
   - **Unresolved** words, with the reason each was left: decide the right
     sense, or whether the sentence was cut wrongly.
   - **Created** senses: check each new reading and gloss against a reference
     and the policy. Look for twins of an existing sense
     (`compendium:lookup Q=<headword>`).
   - **Matched** words: scan for wrong picks, especially function words
     (在, 的, 了, 就, 才…) and seed senses whose gloss merges two meanings
     (花 "to spend (money, time) / flower").
3. Propose the fixes; apply the approved ones (see Edits); run the report again.
4. When nothing is unresolved, finish it:
   `bin/rails runner 'Snippets::Finish.call(Snippet.find(<id>))'`. It strips
   the working keys, adds the snippet's senses to its list and categorizes
   them. It refuses, naming the words, while any Chinese word lacks a sense.
5. The report ends with **unused senses** (no list holds them, no token points
   at them), usually leftovers from re-segmenting. Propose removing them.

## Reviewing any word

`bin/rails compendium:lookup Q=<headword>` (or `Q=<english>` to search glosses)
shows each sense with its id, the lists that hold it and their category there,
and how many snippet sentences use it. Fix what is wrong with the edits below.

**Splitting a merged sense** (花 "to spend / flower"): `revise` it down to one
meaning, `add` the other, `attach` the new sense to the lists it belongs in, and
`repoint` any snippet tokens that mean the new one. Learners keep their progress
on the narrowed sense; mention that to the user.

## Edits

Run each through `bin/rails runner '…'`; group a batch in one runner call.

Token edits (`Snippets::Review`), on a processed snippet:

```ruby
sentence = SnippetSentence.find(12)
Snippets::Review.repoint(sentence, 3, Sense.find(456))       # an existing sense
Snippets::Review.add_sense(sentence, 3, reading: "huā", gloss: "to spend")
Snippets::Review.resegment(sentence, "花了 is 花 + 了")        # re-cut, re-resolve
```

Sense edits (`Compendium::Edit`), on any sense:

```ruby
Compendium::Edit.add(headword: "花", reading: "huā", gloss: "to spend")
Compendium::Edit.revise(Sense.find(456), gloss: "flower")     # or reading: "…"
Compendium::Edit.remove(Sense.find(789))                      # refused if in use
Compendium::Edit.attach(Sense.find(456), WordList.find(3), category: "verb")
Compendium::Edit.detach(Sense.find(456), WordList.find(3))
```

- A token's index counts every token, punctuation included, from 0.
- `add`, `add_sense` and `revise(reading:)` match an entry on the reading's
  letters, so 'kě’ài' and "kě'ài" are the same entry.
- `remove` refuses while a token, list or learner uses the sense; read the
  refusal back to the user rather than working around it.

## Pushing

1. `bin/rails compendium:push` is a **dry run**: it reports adds, updates and
   deletes per table, then the learner data the deletes would take
   (`skill_scores lost`, `sense_distractors lost`). Local copies hold no learner
   data, so this is the only place that cost shows. Read it back to the user.
2. It refuses while any snippet is in progress, if production changed since the
   pull, if migrations differ, or if `COMPENDIUM_USERNAME` is not set in
   `.env.local`. Explain the refusal; do not work around it.
3. Only on the user's explicit go-ahead: `DRY_RUN=false bin/rails
   compendium:push`.
