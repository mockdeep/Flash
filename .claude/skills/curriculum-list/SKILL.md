---
name: curriculum-list
description: Build or revise a CEFR-level word list (A1 … C2) for a language in Flash — situations from the CEFR descriptors, a drafted word list per situation, a fresh review, checks against published lists, the user's approval, then matching against the compendium, loading and pushing. Use when the user wants to write, review, extend or replace a level's word list for any language, or plan a set of level lists for a new language.
---

# Curriculum list

Our level lists are our own: built from what a learner at that level needs to
*do*, in the variety they'll actually hear, then checked against published
lists rather than copied from one. Brazilian Portuguese A1–C2 was the first
set; its examples below are marked as such.

**Why not adopt a published list:** many are tied to one variety (the old
Brazilian Portuguese A1 list was a European Portuguese one, with European
forms and padding phrases), frequency lists skew toward their corpus and miss
everyday words, and the best-made ones (English Vocabulary Profile) can't be
reused. Published lists are checks, not bases.

## Rules the user has set

- **Phrases:** a multi-word phrase is a card only when its meaning is more
  than the sum of its parts (idioms, set greetings, fixed connectors). A
  phrase that just adds up its words is its words. Fixed names for things
  (a technical term, an institution) are allowed.
- **One row per meaning:** a word with two meanings is two rows. Never join
  two meanings in one gloss with a slash or semicolon.
- **Synonyms aren't duplicates.** A different word with the same meaning
  stays; only the same word with the same meaning is a repeat. A synonym
  that is rare or register-bound moves up a level instead. Agents propose
  these drops at every level; don't pass them on.
- **Cognates stay.** A word with the same form and meaning as English still
  gets a card at its level: it teaches spelling, gender and stress, and some
  are false friends. Tell mapping agents not to drop them.
- **Both forms when both are common**, even with the same gloss (Portuguese:
  *sentar* and *se sentar*).
- **The variety's own usage**, spelling and word order, not a neighbor's.
- **Glosses in American English**, as the compendium is.
- Ask the user one question at a time; they approve every change before it
  is written.

## Before the first level: settle the language's conventions

Agree these with the user once per language, and put them in every agent's
prompt:

- **The variety** (Brazilian vs European Portuguese, Latin American vs
  Peninsular Spanish…) and what to flag as the other one.
- **How headwords are written:** the language's `Lexicon` decides whether
  nouns carry an article (in the `article` column, never the headword),
  whether entries have readings, and which form is the lemma (masculine
  singular adjectives, infinitives). Settle the variety's own choices too,
  such as how reflexive verbs are written (Brazilian Portuguese chose
  *se chamar*, its spoken order, over the dictionary's *chamar-se*), and
  how names, titles and plural-only nouns appear.
- **Check sources:** CEFR-J (A1–B2) and Octanove (C1–C2) map from English and
  work for any language. Add the language's own official lists where they
  exist (Goethe for German, the Instituto Cervantes plan for Spanish) and any
  existing list for that level in the app.

## Steps

### 1. Situations

Pull the level's descriptors from the CEFR Companion Volume (coe.int blocks
automated fetches, so ask the user for a local copy of the PDF).
`pdftotext -layout` it to the scratchpad and pull out the level's rows by
scale. Turn them into concrete situations plus a **core** bucket (function
words and common verbs at A1; connectors, abstract verbs and collocations
higher up). Lower levels are about tasks (greetings, shopping, directions);
from B2 up they're about argument, register, nuance and reading. Mark any
situation the descriptors don't name as "our addition". The user approves
the list.

At C1 and C2, also settle the **size and the test** with the user before
drafting: frequency falls off fast, and published charts count words
recognized, not words used. Brazilian Portuguese chose a recognition test at
C2 ("a learner will meet it regularly in serious reading") and about 1,500
meanings, leaving the long tail to the text decks.

### 2. Draft

Write the words per situation yourself, in the session, to
`tmp/curriculum/<lang>/<level>_draft.psv`
(`situation|headword|article|gloss|pos|note`). Each word once, under its main
situation; `note` for variety-specific choices. Above A1, the lower lists are
the floor: don't repeat their meanings, but do add new meanings of their
words. Export every lower list to a file so the agents can check against it.

Before handing the draft over, clean it by script: move any article written
into a headword into its column, put verbs in the agreed form, drop
sum-of-parts phrases, and check against the lower lists (same word and
article, a shared gloss word). A draft written from memory repeats
lower-level meanings under synonyms; keep only real new meanings.

### 3. Fresh review (background agent)

Give a fresh agent the draft, the situation key and the conventions, not
your conclusions. It writes `<level>_review.psv`
(`action|situation|headword|article|gloss|pos|reason`, action `drop` /
`move` / `fix` / `add`), judging variety usage, level, gloss and the phrase
rule, with a cap on additions per situation (8 worked through C1; 15 at C2).
Above A1 it gets the lower lists too, and may `move` a word down a level the
lower lists missed.

Tell every agent the output rules, since each has broken them: one meaning
per gloss, short part-of-speech labels (`noun`, `verb`, `adj`, `adv`,
`prep`, `conj`, `pron`, `det`, `interj`, `phrase`, never blank), the article
filled in on every noun row, and drop/move rows copied exactly from the
draft. Check the files for joined glosses (`;`) and blank parts of speech
before merging.

### 4. Checks (in parallel with 3)

- **CEFR-J** (A1–B2; GitHub `openlanguageprofiles/olp-en-cefrj`, into
  `tmp/curriculum/sources/`; free with citation): an agent maps each entry
  at the level to the draft by meaning. **Octanove** (C1–C2, same repository,
  CC BY-SA 4.0) works the same way; use both as checks, not lists to copy.
  Both lean on English school textbooks, so most entries are covered or
  skipped.
- **Give the mapping agent a strict test from the start:** "would a learner
  at this level clearly need this, often?" (or the recognition test agreed
  for C1–C2), with each candidate marked `add`, next level, or `drop`, and a
  situation for each add. From B1 up the candidates run to thousands, so
  this one pass replaces a separate trim; if it splits the work, every batch
  gets the same test and examples. Save the next-level picks: they join the
  next level's candidates, along with the lower level's skips marked
  "not this level".
- **Words below the level:** at higher levels these sources turn up everyday
  words the lower lists missed. Have the mapping agent mark them `lower`.
- **The old list or official list:** diff it against the draft and sort
  what's missing into real gaps, sum-of-parts phrases, the wrong variety,
  and not this level.

### 5. Merge, place and approve

Merge the sources into `<level>_changes.psv` with a `sources` column,
combining additions with the same word and meaning and dropping any that
break the phrase rule. Glance over what the merge treats as already covered
and as one meaning: a shared English word can hide two meanings of one
word in the target language, and a synonym is not "covered". Apply drops and moves by
word and gloss, matching the article only when the row gives one, and warn
on any that match nothing.

Ask the user what to do with the `lower` words and anything a reviewer moved
down. When there are many, a fresh **placement agent** gives each a level
(A2 up to the current one) and a category, checking every list for repeats;
the user reviews them grouped by level, and the load adds them to those
lists.

Present the rest to the user: first everything two or more sources agree on
(for bulk approval), then single-source ones grouped by situation. Mark
approvals in a `decision` column.

### 6. Match against the compendium

A runner script builds the final rows (draft plus approved changes, each
tagged with its target list) and matches each to an existing sense by
headword, article and gloss: `same`, `similar`, `other-senses` or `new`. Go
through every non-`same` row by hand into `<level>_partial_decisions.psv`:

- **reuse** when it's the same meaning in other words, so learner progress
  carries over. Keep the existing gloss unless it's wrong; check
  `SnippetSentence.pointing_at` first, since a revised gloss shows in snippet
  popovers.
- **new** when the matcher picked a different meaning (it falls back to a
  word's only sense, whatever it means).
- **drop** when it repeats a lower list after all.

A word with several senses matches nothing and shows `sense_id` 0; pick the
sense yourself. The matcher ignores bracketed words, so two rows can land on
one sense; mark one `new`, and let these decisions override any `same`
match. A match onto a sense already in a lower list is a new meaning or a
repeat, never a reuse.

### 7. Load

A runner script, in one transaction: creates the level's list (owned by the
lower lists' owner) or replaces its contents; reuses senses, adds new ones
with `Compendium::Edit.add`, applies approved gloss changes with
`Edit.revise`; appends words placed at lower levels to those lists with
`Edit.attach`; removes what's dropped from the list (the senses stay in the
compendium); and numbers positions in study order (situations, with
greetings and core first at A1). When one sense lands in two lists, it keeps
the lowest level. Have it refuse two rows sharing a sense or a repeat of a
lower list.

**Categories** drive distractors, so nouns go by topic (food-drink, home,
people-family…) and the rest by part of speech (actions, descriptors,
adverbs, function-words), plus `expressions` for greetings and set phrases.
Map each situation to a default noun category and override clear misfits,
keyed by word and gloss where a word's meanings belong apart. Check set
phrases before the "gloss starts with *to*" verb rule (an adverbial phrase
glossed "to go" is not an action). A placed word keeps the placement agent's
category, except that verbs, adjectives and adverbs always take actions,
descriptors and adverbs. Normalize part-of-speech labels agents spell out in
full. Words already in a list keep their category.

Dry-run first and write a category report; scan it for words without an
article in noun categories (a sign of a missing part of speech) before
showing the user.

### 8. Push

`bin/rails compendium:push` (dry run) should show only the lists' changes and
no learner data lost; then `DRY_RUN=false` once the user says so. A learner
with a deck over a list keeps progress on dropped words; those just stop
coming up as cards.

A push never carries decks, so a new list can't be studied until someone has
a deck over it. With the user's go-ahead, run a production runner that finds
the admin and the list and calls `User#reading_deck_over(list, snippet: nil)`;
the user then checks the deck and publishes it with the catalog toggle on its
page.

## Sizes for reference

Published lists: CEFR-J A1 1,164, A2 1,411, B1 2,446, B2 2,778 English
headwords; Octanove C1 1,111, C2 1,025; Goethe's German lists about 650 (A1),
1,300 and 2,400 words by level. Brazilian Portuguese came out at about 890,
1,060, 1,390, 1,440, 1,030 and 1,330 meanings from A1 to C2 (~7,100 in
all). Each level also grew the ones below it, as its checks turned up words
they had missed, so expect the lower lists to keep growing. Above A1, most
additions come from CEFR-J or Octanove alone, so expect a long
single-source review.
