---
name: compendium-review
description: Review Chinese, Portuguese or Filipino vocabulary in Flash's compendium with the user — walk a processed snippet (unresolved words, new senses, wrong picks), look into and fix any word or sense, finish a snippet, and push the results to production. Use when the user wants to process, review or finish a snippet, check or fix a gloss, reading or sense, split a merged sense, or push compendium changes.
---

# Compendium review

The compendium (entries, senses, word lists, snippets) is edited **locally** and
copied to production by `compendium:push`; production never edits it. Your job
in a review is to find what is wrong, explain it, propose fixes, and apply only
what the user agrees to. AGENTS.md ("Snippet Processing", "Compendium Review",
"Compendium Sync") has the details behind every command here.

## Working with the user

- **The user does not read Mandarin, and is learning Portuguese.** Explain
  every finding in English: the word (with its pinyin, for Mandarin), the
  gloss, and why it is wrong or right *in this sentence*.
- **Back each judgment with a reference**, not your own say-so. Mandarin:
  CC-CEDICT (look the word up on mdbg.net) or Wiktionary. Portuguese:
  Wiktionary, Priberam or Michaelis (Michaelis for Brazilian usage).
  Filipino: Wiktionary or tagalog.com, and the UP Diksiyonaryong Filipino
  for accents. Where
  references disagree or the call is a policy question, say so and let the
  user decide.
- **Judge against the language's card rules**, and read them at the start of
  a review: `app/actions/snippets/mandarin/policy.rb` for Mandarin
  (segmentation, readings, function words), the prompts in
  `app/actions/snippets/portuguese.rb` for Portuguese and
  `app/actions/snippets/filipino.rb` for Filipino (segmentation, glosses,
  skips).
- **Propose fixes in batches and wait for approval** before running any edit.
  Reading commands (`snippets:review`, `compendium:lookup`) need no approval.
- Keep it brief: a short table of findings beats paragraphs.

## Before a session

1. The local database should match production. If unsure, run
   `bin/rails compendium:pull` (the user must stop the dev server and jobs
   worker first). It refuses while local work is unpushed; never pass
   `FORCE=true` without the user saying so, since it discards that work.
2. Sources and their snippets are added in the app (`/sources`, admin only,
   where a source's language is chosen), locally or in production. One added
   in production arrives with the next pull.

## Processing

`bin/rails snippets:process` segments and resolves every unprocessed sentence
through the Claude CLI, printing a line per batch. `ID=<id>` keeps it to one
snippet: for a book added whole, process the next snippet only once the last
is finished and pushed, since a processed snippet blocks pushing until it is
finished. It takes a while on a long
text, so run it in the background and report when it finishes. Lines starting
"Re-segmented" name a sentence sent back to the segmenter and why.

## Reviewing a snippet

1. `bin/rails snippets:review ID=<id>` (no `ID`: every unfinished snippet).
   The report gives sentence ids, token indexes and sense ids (`#123`), which
   every edit takes.
   - **A long snippet goes a stretch at a time**: about 100 sentences a
     session, with `FROM=1 TO=100`, then `FROM=101 TO=200` and so on. Each
     sentence is numbered out of the snippet's ("101/412"); at the end of a
     session, tell the user where to pick up. Unresolved and skipped words
     keep to the stretch; created senses cover the whole snippet, so check
     them in the first stretch only.
2. Work through it in this order:
   - **Translations** of the source's title and the snippet's heading, which
     show under them wherever the deck or text is named: suggest English for
     any marked `missing`, short enough for a deck box ("Spring Festival").
     They don't block finishing.
   - **Unresolved** words, with the reason each was left: decide the right
     sense, or whether the sentence was cut wrongly.
   - **Skipped** words, which get no card: in Portuguese and Filipino, names English
     leaves as they are, people's or places' (`name`), and titles or other
     names left in another language (`foreign`). Check each reason holds.
     Give a wrongly skipped one a sense with `add_sense` or `repoint`, which
     takes the skip off. A name English calls something else (Lisboa
     "Lisbon", Deus "God") gets a card; one that slipped through with a
     gloss that only repeats it should be skipped instead.
   - **Created** senses: check each new reading and gloss against a reference
     and the policy, and for Mandarin the traditional form in brackets (发
     "hair" is 髮, not 發). Look for twins of an existing sense
     (`compendium:lookup Q=<headword>`).
   - **Matched** words: scan for wrong picks, especially function words
     (在, 的, 了, 就, 才…) and seed senses whose gloss merges two meanings
     (花 "to spend (money, time) / flower"). A pick is right only if its
     gloss could stand in for the word in an English rendering of the
     sentence: 健康 "healthy" is wrong in 人体健康 "human health".
   - **Portuguese**, beyond the above:
     - A word keeps the form the text gives it: *falávamos* is its own entry,
       not *falar*. The headword is the word in lower case, but names, titles
       before them and Roman numerals keep their capitals. A title (*D.*,
       *Sr.*, *Dr.*) is its own word with a card, apart from the skipped name.
     - The gloss renders that form, tense and number included ("we were
       speaking", "houses"), with a subject only when the form fixes one:
       *falava* is "was speaking". No dictionary form, grammar labels or
       Portuguese in a gloss.
     - Contractions (*do*, *pelo*, *dele*), verbs with joined pronouns
       (*diga-me*) and fixed phrases whose meaning isn't the sum of their
       words (*de repente*, *por causa de*) are one word. A transparent
       combination is split.
     - Function words take the sense their job here needs: *que* "that" /
       "which" / "than", *se* "if" / "oneself", *a* "the" / "to", and a
       contraction as used (*da* "of the" / "from the").
     - There are no readings: a sense has a gloss alone.
   - **Filipino**, like Portuguese where it isn't said otherwise:
     - A word keeps its affixes and the accents the text writes: *kinakain*
       and *kumain* are their own entries, not *kain*, and *bukás* "open"
       and *búkas* "tomorrow" are two. A headword that drops or adds an
       accent is wrong.
     - A verb's gloss carries its aspect and focus: *kumain* "ate",
       *kumakain* "is eating", *kinain* "was eaten".
     - A word with a joined linker (*isang*), a shortened *at* or *ay*
       (*kaya't*, *siya'y*) or a hyphen (*tuwang-tuwa*, *nag-iisip*) is one
       word.
     - Markers and particles get cards: an English word where one does the
       job (*sa* "to", *lang* "only"), else a short label in brackets (*ang*
       "(topic marker)", *mga* "(plural)", *po* "(polite)"). *na* takes the
       sense its job needs: "already" or "(linker)".
     - Titles (*Don*, *Padre*, *G.* written out as *ginoo*) get cards,
       studied in lower case, as is any word the text capitalises out of
       respect (*hari*, *heneral*); only names, peoples, languages, months,
       days and holidays, and words made from a place's name keep a
       capital; Spanish or Latin left as it is is skipped as `foreign`.
     - Nouns are glossed singular (*mga* marks the plural), verbs "is" or
       "was" unless the form marks a plural subject (*nagsialis*), and
       pronouns of either gender with both ("he, she").
3. Propose the fixes; apply the approved ones (see Edits); run the report again.
4. When nothing is unresolved, finish it:
   `bin/rails runner 'Snippets::Finish.call(Snippet.find(<id>))'`. It strips
   the working keys, adds the snippet's senses to its list and categorizes
   them. It refuses, naming the words, while any word that isn't skipped lacks
   a sense.
5. The report ends with **unused senses** (no list holds them, no token points
   at them), usually leftovers from re-segmenting. Propose removing them.

## Reviewing any word

`bin/rails compendium:lookup Q=<headword>` (or `Q=<english>`; it matches headwords
and searches glosses; add `IN=<code>` for another language, `IN=pt` for Portuguese) shows each sense with its id, the lists that hold it and their category there,
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
Snippets::Review.add_sense(sentence, 5, reading: nil, gloss: "we were speaking") # Portuguese
Snippets::Review.resegment(sentence, "花了 is 花 + 了")        # re-cut; changed tokens re-resolved
```

Translations, by the ids the report gives:

```ruby
Source.find(3).update!(title_translation: "Spring Festival")
Snippet.find(6).update!(heading_translation: "Customs")
```

Sense edits (`Compendium::Edit`), on any sense:

```ruby
Compendium::Edit.add(language: "zh", headword: "花", reading: "huā", gloss: "to spend")
Compendium::Edit.add(language: "pt", headword: "casas", reading: nil, gloss: "houses")
Compendium::Edit.revise(Sense.find(456), gloss: "flower")     # or reading: "…"
Compendium::Edit.revise(Sense.find(456), traditional: "乾")    # a Mandarin sense's traditional form
Compendium::Edit.remove(Sense.find(789))                      # refused if in use
Compendium::Edit.attach(Sense.find(456), WordList.find(3), category: "verb")
Compendium::Edit.detach(Sense.find(456), WordList.find(3))
```

- A token's index counts every token, punctuation included, from 0.
- `add`, `add_sense` and `revise(reading:)` match an entry on the reading's
  letters, so 'kě’ài' and "kě'ài" are the same entry.
- A Mandarin sense made with `add` has no traditional form: give it one with
  `revise(sense, traditional:)`. `add_sense` takes the token's.
- Each traditional spelling of a meaning is a sense of its own (想像 and 想象
  "imagination"); don't merge senses that differ only in traditional form.
  Finish puts a traditional text's spellings on its senses.
- `remove` refuses while a token, list or learner uses the sense; read the
  refusal back to the user rather than working around it.
- Never clear out a language's entries wholesale: the compendium holds seed
  lists (such as "Portuguese (Brazilian) A1") alongside what snippets
  created. Remove only senses `snippets:review` lists as unused.

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
