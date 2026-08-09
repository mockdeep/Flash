# Compendium

Design for a single shared vocabulary store ("the compendium") that all language
decks select from, replacing per-deck language data_sets. Status: **phases 1–2
of Build sequencing are shipped** (2026-08: study-engine interface extraction,
then the Basic/Music flat-card pass — `data_sets`/`items`/`pairings` are now
language-only). The compendium evolution itself (phase 3) is unbuilt. The
content pipeline was prototyped against real texts in 2026-08 (see Prototype
findings).

## Goals

- One canonical record per word per language. Fixing a gloss fixes it everywhere.
- Decks are *selections over* the compendium, not owners of copied content.
- Progress belongs to the user × word-sense × skill, independent of deck. Studying
  a word in any deck advances the same streak; reading and writing streaks are
  separate.
- Support texts as a first-class source: a book's chapters become word lists, so a
  reader can study a chapter's vocabulary before reading it.
- Multi-language from the start (Mandarin first). Language-specific needs live in
  nullable columns, not Mandarin-shaped tables.
- Sharing by reference: a shared deck is a visibility flag, not a copied data_set.

## Schema

```mermaid
erDiagram
    lexicons ||--o{ entries : ""
    lexicons ||--o{ word_lists : ""
    entries ||--o{ senses : ""
    senses ||--o{ sense_memberships : ""
    word_lists ||--o{ sense_memberships : ""
    texts ||--o{ chapters : ""
    chapters ||--o{ word_lists : "chapter lists"
    word_lists ||--o{ decks : "selection"
    users ||--o{ decks : owns
    users ||--o{ skill_scores : ""
    senses ||--o{ skill_scores : ""
    senses ||--o{ sense_examples : ""
    senses ||--o{ sense_distractors : ""
    users ||--o{ sense_distractors : ""

    lexicons {
        string language "unique; zh, ja, es..."
    }
    entries {
        bigint lexicon_id FK
        string headword "e.g. 爱好"
        string reading "pinyin w/ tones; furigana; null where n/a"
        string script_variant "zh: traditional form"
        integer frequency_rank
        string kind "word | proper_noun"
    }
    senses {
        bigint entry_id FK
        string gloss "one meaning; may hold synonym facets"
        string pos
        string register "modern | literary"
        integer rank "1 = primary"
        string source "cedict | llm | curated"
        string status "auto | reviewed"
    }
    texts {
        string title
        string author
        bigint user_id FK "null = system/public-domain"
    }
    chapters {
        bigint text_id FK
        integer position
        string title
        text body "retained source; re-runs, audit, future reader"
    }
    word_lists {
        bigint lexicon_id FK "one language per list; drives fonts"
        string kind "hsk_level | chapter | curated"
        integer hsk_level "when kind = hsk_level"
        bigint chapter_id FK "when kind = chapter"
        bigint user_id FK "null = system"
        string name
    }
    sense_memberships {
        bigint sense_id FK
        bigint word_list_id FK
        integer position "first occurrence in chapter"
    }
    sense_examples {
        bigint sense_id FK
        string sentence
        string translation
    }
    sense_distractors {
        bigint user_id FK
        bigint sense_id FK
        bigint distractor_sense_id FK
        integer miss_count
        datetime last_missed_at
    }
    skill_scores {
        bigint user_id FK
        bigint sense_id FK
        string skill "reading | writing"
        integer correct_count
        integer correct_streak
        integer view_count
    }
    decks {
        bigint word_list_id FK "the selection; null for Basic/Music"
        bigint user_id FK
        string type "ReadingDeck | WritingDeck"
        string name
        string visibility
        integer level "streak-window selection, as today"
    }
```

Key uniques:

| Table | Unique on |
|---|---|
| entries | (lexicon_id, headword, reading) |
| chapters | (text_id, position) |
| senses | — (rank orders within entry) |
| sense_memberships | (sense_id, word_list_id) |
| skill_scores | (user_id, sense_id, skill) |
| sense_distractors | (user_id, sense_id, distractor_sense_id) |

## Core concepts

### Entry vs. sense

- **Entry** identity is headword + reading within a lexicon. 还 hái and 还 huán are
  two entries; 花 huā is one entry regardless of meaning.
- **Sense** is the studyable unit — one meaning of an entry. The split criterion:
  *could a learner know one meaning without knowing the other?* 花 flower vs.
  花 to-spend split; "to like" vs. "to be fond of" do not (synonym facets stay
  inside one sense's gloss).
- Over-splitting is tolerated (the seed data is already semicolon-split and can be
  imported as-is). Credit fan-out (below) makes facet-level rows score in lockstep,
  and merging senses later is a local fix: combine rows, keep the max score. The
  cost is cosmetic — inflated "sense counts" on entries.
- Script is a column, not an entry split: simplified is the headword, traditional
  is `script_variant` (per-sense mapping is unambiguous even for one-to-many
  characters like 发, because senses pin the word). Regional *vocabulary*
  differences (软件 vs. 軟體) are separate entries, not script variants.
- Proper nouns (`kind`) are excluded from general vocabulary lists (HSK,
  curated) but belong in text lists: studying to read a chapter means no token
  should be a blank. Name glosses are text-contextual ("Guo Jing — the
  protagonist"), which the pipeline's contextual glossing step produces anyway,
  and progress on a name carries across chapters and sequels like any sense.
  `kind` is presentation metadata (a name badge, maybe a lighter study
  treatment), not a compendium filter. Function words enter text lists on the
  same no-blanks basis, glossed as function ("的 — possessive marker") — weak
  cards that teach recognition rather than mastery, but a weak card beats a
  blank, and past the earliest levels they're already mastered and drop out of
  study on their own. The same logic keeps compositional-but-dictionary-listed
  collocations (不再, 几天) in lists: common-phrase reinforcement beats filtering,
  streaks retire them fast, and the only requirement is that their glosses are
  verified correct — no triviality filter.
- `register` keeps literary/archaic senses (e.g. from Journey to the West) from
  polluting modern decks, and vice versa.

### Deck = word_list × form

A deck owns no content: it points at a word_list (HSK level, book chapter, or a
hand-curated list) and contributes the *form* — reading vs. writing (existing STI),
plus study settings. Consequences:

- Sharing a deck is a visibility flag. No copying, no forking of content on add:
  adding a shared deck creates the adder's own deck row over the same word_list
  (their own level and study settings). Fork = copy the word_list, only needed
  to *edit* the selection — and progress carries across a fork automatically,
  since scores key to senses, not lists.
- Shared lists are living selections: the owner's edits propagate to every
  referencing deck. Safe by construction — progress is keyed to user × sense,
  so list edits can't touch it, and since users never author glosses, a shared
  deck exposes only a selection over canonical senses (the moderation surface
  is list names).
- Revoking a share stops discovery only: the link and preview die, no new adds.
  Decks that already reference the word_list keep working — same outcome the
  old fork-on-add design gave, without the copy.
- HSK levels, chapters, and personal lists are one mechanism.
- The `data_sets`/`items`/`pairings` tables are not needed for language decks
  either, once decks select over the compendium. Basic and Music have already
  exited them onto flat deck-owned cards (phase 2, shipped), so the item
  machinery is language-only today.
- Users never author gloss content into the compendium. A language deck is
  created by selecting existing words/lists, or by supplying words or a text
  that run the content pipeline (senses CEDICT-grounded and LLM-generated).
  Freeform front/back uploads are Basic decks — full freedom, no lexicon
  contact.

### Coexistence with Basic and Music

The compendium replaces `data_sets`/`items`/`pairings` for language decks;
Basic and Music exited that machinery first (phase 2, **shipped 2026-08**)
onto one shared flat model: cards own their content and their progress
directly (`deck_id`, front, back, category, reading, examples, the score
counts, plus a `card_distractors` table for uploaded and miss-recorded
decoys), no data_set indirection. The families differ by STI type and
validation (music backs must match the note format), not table structure. Two
study engines then run side by side — language decks enumerate word_list
senses joined to skill_scores, Basic/Music decks read cards with embedded
scores. Rules:

- **One flat card model for Basic and Music, not a schema each.** Basic is
  freeform: cards owning their content is the correct model, not legacy debt
  (the data_set/items/pairings indirection is language-shaped reuse
  machinery). Music takes the same shape — *not* a compendium echo, though its
  pitch inventory is small and canonical — because the deck's grouping is part
  of what's studied (notes as a group, sequences as windows of cards), so
  progress belongs to the note-in-deck, not the pitch. Pitch-keyed scores
  would let mastery in one deck pre-advance the same notes in another —
  exactly right for words, wrong for music. No shared scores, no credit
  fan-out, no canonical-inventory tables. Split trigger, recorded so it isn't
  re-derived: music cards leave the shared table only if music content becomes
  structured (per-note durations for rhythm checking, notation data) rather
  than a validated string.
- **Deck FK invariant.** Reading/Writing decks set `word_list_id`; Basic/Music
  decks set no content FK at all — their cards reference `deck_id` directly.
  Presence of `word_list_id` iff language family. *Shipped* as a
  presence/absence validation pair on `data_set_id` (the FK renames with the
  table in step 3.5).
- **Topics repoint.** *Shipped.* Topic assignment lives on `decks` for every
  family (matching the deck-page assignment UX). One mechanism across all
  families — and truly per-deck: sibling Reading/Writing decks no longer move
  together as they did when the topic sat on the shared data_set.
- **One study engine, per-family interface.** Study-mode code stays single:
  each family answers "what are your studyable units, their prompts and
  answers, and their score handle." New study features build against that
  interface or are consciously scoped to one family (fuzzy find and the
  reading test are language-only). *Shipped* as: content readers and the
  score handle (`record_correct!`/`record_miss!`) on Card, with a
  `LanguageCard` STI intermediate keeping the item-backed readers; deck-level
  option pools (`cards_in_category`, `reading_pairs`) overridden by
  `LanguageDeck`; and a write-side mirror, `deck.card_writer`, dispatching
  edits/replaces to `Decks::FlatCards` or `DataSets::Projection`. Step 3.6
  swaps the language implementations behind these same seams.

### Study semantics

- **One card per headword per deck.** If a deck's list contains several senses of
  one entry, study mode presents a single card whose back is the union of those
  senses' glosses, rejoined with "; " — the same display as today. The deck itself
  is the disambiguating context for the prompt (seeing 花 in an HSK 1 deck asks
  for what HSK 1 taught). Grouping is by written form, not entry: homograph
  entries (还 hái / 还 huán) would otherwise yield two visually identical fronts —
  an unanswerable prompt, with each card's true answer sitting in the other's
  distractor pool. Merged, the back shows each reading labeled with its glosses,
  and the reading test's correct option is the union of member readings
  ("hái; huán"), with distractors shape-matched by composing pairs from sibling
  cards' readings so a two-reading option isn't a giveaway. Writing decks are
  unaffected — their prompts are glosses, which don't collide.
- **Credit fans out.** Answering that card correctly advances the streak of every
  member sense. Grouping is a study-time construct; nothing about it is stored.
- **A card studies at the level of its weakest member sense.** A card mixing a
  mastered and a new sense behaves like a new card. (No time-based scheduling —
  selection stays streak-based, as today; a `last_studied_at` on skill_scores is
  a trivial later addition if spaced repetition ever arrives.)
- **Grading is member-scoped.** A typed or chosen answer is checked against the
  union of the card's member senses — the same set the card displays. Multiple
  choice and fuzzy find both target this union (fuzzy find matches the full
  joined gloss, not one sense). Synonym-facet safety comes from seeding, not
  grading: facets semicolon-split from one seed row enter lists together, so
  they are usually co-members. A narrow chapter list that links only one facet
  will mark a synonym facet wrong — accepted; the chapter taught a specific
  usage.
- **Distractors are generated; misses are remembered.** No curated distractor
  lists for language decks: option lists build on the fly from sibling cards in
  the deck (length-matched, register permitting). When a user picks a wrong
  option, every member sense the card displayed is linked to every member sense
  the chosen option displayed — cross-product fan-out, mirroring credit fan-out,
  because the displayed grouping is deck-contextual and not stored. Rows are
  per-user (sense_distractors) with a miss count; accumulated misses bias future
  option selection toward that user's actual confusions. A global
  "commonly confused" signal can be derived later by aggregating across users.
- **Cards are not rows.** A study session enumerates the list's senses, joins the
  user's skill_scores for the deck's skill, and applies the existing
  level/streak-window selection. Any user can study any visible deck; their
  progress is their own. Deck-level recency (`decks.last_studied_at`) stays where
  it is, as today.

### Progress

`skill_scores` is per user × sense × skill. Reading and writing advance
independently; both persist across every deck containing the sense.

Known wrinkle, deliberately deferred: writing ability is arguably per *entry* (or
per character — writing 银行 is writing 银 + 行) rather than per sense. Keying both
skills to sense is the consistent v1; revisit if writing decks feel wrong.

### Examples

`sense_examples` holds teaching sentences only, shown on card reveal (today's
items.example / paired_example). Rows enter solely from trusted sources —
seed-account curation, Tatoeba, generated sentences — so everything in the table
is shareable by construction; no flag needed. Quoted-from-text occurrence
evidence is a separate, deferred concept (see Open questions).

## Content pipeline (build-time, per text or list)

1. **Segment** the text into words — LLM segmentation (Sonnet-class, sentences
   batched), **mechanically verified**: the tokens joined back together must
   reproduce the sentence's Han characters exactly (punctuation and quote-glyph
   normalization ignored — the only failure mode ever observed). The check
   guarantees partition *integrity* — no character dropped, invented, or
   substituted — NOT boundary correctness; boundaries are validated semantically
   downstream (steps 4–5). Failed sentences retry singly; a deterministic floor
   (character-level tokens, or jieba) exists but went unreached in prototype
   runs — 517/517 sentences across both registers verified. This handles modern
   and classical text with one mechanism (jieba's classical welds — 故曰, 谓之 —
   don't occur); classical texts stay deferred on deck economics alone (~900 new
   studyable words per 西游记 chapter), no longer on segmentation.
2. **Lexicon lookup first** — known senses cost nothing and inherit user progress.
   Lookup indexes both headword and script_variant, so traditional and simplified
   sources both match. Pure-number tokens drop; era spellings with a modern form
   (甚么 → 什么) map as variants.
3. **New words → contextual glossing**: the LLM receives the sentence plus the
   CC-CEDICT entry and picks/trims the sense that fits. CEDICT (a ~9 MB reference
   table server-side, never user-facing) is there for gloss *convergence*, cheap
   verification, the not-a-word tripwire, and pinyin — not because the LLM can't
   translate.
4. **Match step**: which existing sense does this usage select? Selection is the
   real question (memberships attach at the sense level, and picking the sense
   resolves homograph readings as a side effect); measured at 100% for
   same-reading splits, ~96% when a tone-pair reading is at stake (see Prototype
   findings). If no sense fits, create one (source: llm, status: auto), with
   `register` set from the text's context so literary senses stay out of modern
   decks. The sense inventory grows lazily from real usage.
5. **Misses route, they don't fail**: not-in-CEDICT means proper noun (→ into
   the chapter list, glossed contextually), segmentation artifact (→ re-segment
   check), or a real rare word
   (→ ungrounded gloss with heavier checks: "real word / name / artifact?" asked
   explicitly, cross-occurrence agreement, back-translation, review queue).
6. **Propose → confirm**: every LLM assertion (new-sense claims, glosses, miss
   routing) is proposed by one model and independently confirmed by a tier-above
   judge, calibrated to actually reject — the flash-csvs pattern. Prototype rates:
   ~43% of new-sense proposals rejected on modern text, ~10% of glosses fixed.
   Nothing enters the compendium on a single model's say-so.
7. **Chapter word_lists** get sense_memberships with first-occurrence positions;
   dedup against earlier chapters happens by construction (the sense already
   exists and the user may already have scores).

Because step 1 verifies integrity but not boundaries, boundary errors are the one
class that reaches later stages, and each kind meets a net: an over-merge either
fails lookup (→ routed as artifact) or accidentally forms a real dictionary word
(靠着火 → 着火) and then surfaces as a match-step proposal whose sense doesn't fit
the sentence — the confirm tier rejects it and feeds a re-segmentation check. An
over-split whose pieces are real words is the weakest-checked case: a piece whose
gloss clashes with the context still trips the match step, but a contextually
plausible split passes silently — worst case an *omitted* compound card, never a
wrong one.

## Prototype findings (2026-08)

A throwaway prototype ([compendium_prototype/](compendium_prototype/); claude-CLI
scripts in the flash-csvs idiom, intermediates regenerate into tmp/) ran the full
content pipeline — segment → lookup → gloss/match/route (Sonnet) → confirm
(Opus) — over two public-domain texts, with the HSK 1–7 deck standing in as the
lexicon:

- **孔乙己 (Lu Xun, 1919 — modern)**: 1,382 tokens, 605 studyable words; 75% of
  tokens already on HSK cards; ~200-word new-vocab chapter deck. After confirm,
  8.8% of known words genuinely needed a new sense (散 "knock off work", 文 the
  coin, 道 "said"). This is the product the doc describes, working.
- **西游记 ch. 1 (Ming)**: under jieba, token coverage 49%; 719 CEDICT misses,
  mostly welded classical function words; ~900 new words in one chapter. Glossing
  judgment held up fully (earthly-branch senses of 子/丑/未, classical 也, cípái
  titles, 须菩提 as Subhuti) — the blockers were segmentation (since solved, next
  bullet) and deck economics, which alone sustains the classical deferral.
- **LLM vs jieba segmentation** (`01b-segment-llm.rb` + `05-seg-diff.rb`): Sonnet
  segments sentences under the Han-reconstruction check — 517/517 sentences
  verified across both texts once quote-glyph normalization (the only failure
  cause ever logged; zero Han-content errors) was excluded from comparison.
  Unique-word miss rate: modern 21.6% → 6.5%, classical 42.5% → 17.9%; none of
  the dangerous cross-boundary welds occurred; names and idioms arrive whole
  (咸亨酒店, 东胜神洲, 好喝懒做). Consequence: step 1 is LLM-primary; jieba
  is retired to a never-reached deterministic floor.
- **Full chain over LLM segmentation** (slug `kongyiji-llm`): machine-verifies
  the segmentation claims that the diff reports made by inspection. All 12
  match-step rejections were sense-nuance; zero were disguised boundary errors
  (the jieba baseline had 4). Routing found no real artifacts (2 verdicts, both
  overturned by the confirm tier as real words), no shrapnel-type misses, and
  match proposals were fewer and more precise than the jieba baseline (36 vs 56
  judged; 67% vs 57% confirm precision). Span-scoped re-segmentation repair is
  understood (boundary-shift errors implicate neighbors; artifact parts that
  don't resolve are the tell) but stays unbuilt — no observed need.
- **Sense selection** (`06-sense-select.rb`): the match step's "which sense?"
  judgment, measured against flash-csvs ground truth (85 multi-level headwords
  with disjoint glosses × their judge-verified example sentences, 124 items).
  Sonnet single-pass: 96.8% overall; **100% on same-reading sense splits** — the
  case memberships and credit fan-out depend on; 95.6% on homograph/reading
  resolution, with all 4 misses being tone-pair readings whose senses nearly
  coincide (转 zhuǎn/zhuàn, 炸 fry/explode). No confirm tier needed for
  selection; adjacent-sense homographs are the only escalation candidates.
- **Entry resolution** (`resolve.rb`, read-only dry run of the migration's
  entry-resolution step):
  100% of dev-DB zh fronts resolve cleanly by headword + reading, with a toneless
  fallback absorbing sandhi differences. **Production run (2026-08, 31,312 zh
  fronts via CSV export)**: after two mechanical text normalizations — stripping
  parenthesized traditional variants ("枪 (槍)", 3,914 rows, maps to
  `script_variant`) and homograph superscripts ("过⁰", 19 rows, an artifact of
  the unique-front index) — only **7 fronts fail to resolve**, all copies of 3
  compositional phrases from old seed decks (车上, 放到, 能不能),
  pipeline-glossable. Zero reading_mismatch anywhere: items either carry exact
  seed readings or no reading at all. The one sizable bucket is
  no_reading_ambiguous (2,209 rows — multi-reading characters like 的/了/和 in
  decks that never stored readings), and it mostly dissolves: those decks are
  largely forks that collapse to system word_lists without item-level
  resolution, and headword-grouped cards absorb the rest (a reading-less 的
  maps to the merged 的 card regardless of which entry was "meant").

Net: every LLM judgment in the pipeline is now measured — segmentation
(mechanically verified), sense creation (propose→confirm), glossing, routing,
and sense selection. Still untested: study-time semantics (credit fan-out, card
grouping), which are ordinary app code, and cross-chapter lexicon growth over a
full book.

## Seeding

- The existing hand-curated HSK data_sets are the seed: vetted word + level +
  gloss rows. Their semicolon-split glosses import as individual senses (facet
  over-splitting accepted, see above).
- Cross-level gloss differences for the same headword are *signal* — HSK levels
  teach different senses of the same word (花 flower @1, spend @higher). Same
  meaning → merge; different meaning → separate senses with separate level
  memberships.
- HSK official lists carry no sentences or sense annotations; context for
  list-sourced words comes from Tatoeba, level-constrained LLM-generated
  sentences, or community datasets. (The curated decks canNOT double as an
  engine validation set — they are themselves output of the flash-csvs
  pipeline, so the diff would be circular. Engine validation came from the
  2026-08 text-prototype runs instead; see Prototype findings.)
- Useful community data: [drkameleon/complete-hsk-vocabulary](https://github.com/drkameleon/complete-hsk-vocabulary)
  (MIT; both HSK versions, frequency, POS, traditional, cleaned CEDICT glosses).

## Deck migration

Executes inside the Build sequencing ladder (phase 3), not as a one-shot event.

1. **Seeding is the backfill.** Entries and senses backfill directly from the
   curated HSK data_sets (steps 3.2 and 3.4, see Seeding), so matching
   targets exist by construction before any fork row resolves.
2. **Forks of catalog data_sets resolve, then collapse.** Nearly every
   non-seed data_set is a copy of a seed-account catalog deck. During the
   backfills their rows resolve to the same entries and senses as the
   originals — stale copies (parenthesized-traditional fronts, missing
   readings, since-removed words like 车上) resolve all the same, and
   copy-era modifications are discarded (dumped to a migration log, not
   silently lost). Study counts carry as best they can: scores migrate per
   resolved front (see Progress scoring migration) and key to senses, not
   lists, so progress on a word a list dropped persists as skill_scores and
   resurfaces in any deck containing that sense. Collapsing the now-redundant
   fork word_lists onto system lists is cleanup (step 3.7), identified by
   provenance — a majority of the deck's cards tracing via
   `cards.source_card_id` to a seed-account card (column added 2026-05; older
   forks lack it) — with exact name match as the fallback, since the copy
   flow copies the source's name verbatim. Low-stakes and optional, since
   progress keys to senses either way. Users edit selections, not senses;
   personal gloss edits have no home in the new model (per-user overrides are
   parked — see Open questions). This removes the premise of the
   copy-and-suggest-back catalog flow — its successor, if any, is sense-level
   edit proposals.
3. **Seed-account LanguageDataSets that aren't HSK levels** become curated
   word_lists. Items resolve to entries by headword + stored reading (CEDICT
   fallback when reading is missing); glosses are trusted curation and import
   verbatim as senses (source: curated), same standing as the HSK seed. Items'
   example / paired_example import as sense_examples rows, fanned out to the
   same senses the item's gloss mapped to.
4. **The residue is handled by hand, not policy.** With the current user base,
   data_sets that are neither seed-owned nor identifiable forks number a
   handful at most. The step-3.4 dry-run report lists them; each is
   settled manually — word-shaped items resolve through the pipeline
   (CEDICT-grounded, source: llm, status: auto; the user's gloss is a matching
   hint only, and user wording never enters the lexicon), and sets that were
   never word-shaped convert to Basic decks. No thresholds or automated
   mixed-set rules; the trust split is guidance for the manual pass, not an
   algorithm.
5. **No deck repoint.** data_sets *become* word_lists (the step-3.5 rename);
   decks keep their FK under the new name. Deck STI (Reading/Writing) is
   unchanged.
6. **Scores migrate at step 3.6** (next section), once the card → sense
   mapping exists.

## Progress scoring migration

Step 3.6 of the Build sequencing ladder. Existing card progress
(`correct_count`, `correct_streak`, `view_count`) must move
to skill_scores keyed by the senses each card's item maps to (fan-out: a card
covering multiple glosses seeds each matched sense's row; conflicts keep max).
Deck type determines skill (ReadingDeck → reading, WritingDeck → writing).

## Build sequencing

Four phases. The first two — user-invisible groundwork — are **shipped**;
phase 3 evolves the language tables *in place* — no parallel system, no
cutover event — and phase 4 builds the new capability on the stable result.
The shipped phases set the working pattern for phase 3: many single-concern
PRs, each merged and deployed before the next, dry-run/verification checks
around every backfill.

1. **Study-engine interface extraction.** ✅ *Shipped 2026-08-07.* Pure
   refactor, no schema change: study modes ask a deck family for its studyable
   units, their prompts and answers, and their score handle (the interface
   from Coexistence). Extracted while every family still sat on the data_set
   model, so the refactor was behavior-preserving by construction.
2. **Flat-card pass (Basic + Music together).** ✅ *Shipped 2026-08-08* as a
   ladder of single-concern PRs, each deployed before the next (details in
   git history). Content moved from items onto cards (plus
   `card_distractors`), topics repointed to decks, decks gained `name` (flat
   families) and `user_id` (*every* family — owners never change, and
   phase 3 wants it), and the Basic/Music data_sets and items were deleted.
   No user-visible change beyond per-deck topic assignment.
3. **Compendium evolution.** After phase 2 the data_set machinery is
   language-only, and its tables map nearly 1:1 onto the compendium: items
   (front side) → entries, pairings + back items → senses + memberships,
   data_sets → word_lists, cards → skill_scores. Each mapping is one
   add → backfill → switch reads/writes → drop-old step, deployed and
   verified before the next. The Deck migration section's concerns execute
   inside these backfills rather than as a one-shot event.
   1. **Dry-run report tooling.** Port the prototype's read-only resolvers
      into the app as report tasks (entry resolution first; sense resolution
      follows for 3.4) before any write exists. Every backfill below ships
      only after its report runs clean against production — the discipline
      the flat-card pass followed with ad-hoc queries, made reusable.
   2. **Canonicalize entries.** Add `lexicons` + `entries`; backfill by
      deduping front items across data_sets (the resolution `resolve.rb`
      proved: 31,312 production fronts, 7 failures); items point at their
      entry. Enrichment (script_variant, frequency_rank) joins from the
      community HSK dataset. No behavior change.
   3. **Upload resolution.** Language CSV ingest resolves words against
      entries from here on — reject-with-message for unresolvable words
      first; a pipeline-lite gloss step can upgrade it later. Its own rung
      so the decision lands before sense extraction depends on it, not
      inside it.
   4. **Extract senses.** Backfill `senses` from back items — the trust split
      runs here: seed-account rows import as canonical (source: curated),
      fork rows resolve to them, residue data_sets settle by hand (see Deck
      migration). Pairings become sense_memberships (list × sense, position).
      One sense per back item initially; the semicolon split comes later
      (step 3.7). Display unchanged.
   5. **Rename data_sets → word_lists** (+ `kind`, `hsk_level`). Decks keep
      their FK under the new name — no repoint.
   6. **Globalize progress** — the lumpiest step, so it runs as the phase-2
      ladder: (a) add `skill_scores` and backfill from cards (max per
      user × sense × skill; deck STI gives the skill), study dual-writes
      while card counters stay authoritative; (b) switch study reads to
      sense enumeration — headword grouping, credit fan-out, and
      weakest-member selection land here, verifiable against the still-live
      card counters; (c) drop language rows from `cards`. This is the step
      where scores stop being per-card.
   7. **Semantic upgrades, one step each:** semicolon sense-splitting
      (display already joins with "; ", so invisible); generated distractors
      + `sense_distractors`, dropping `item_distractors`; sharing by
      reference (possible once progress has left the cards); collapsing fork
      word_lists onto system lists — now optional dedup, not a load-bearing
      migration.
   8. **Retire the item layer.** Language edit/replace flows move off the
      projection onto sense selections, then `items`/`pairings` and the
      projection itself drop. Unscheduled anywhere else, and it can't ride
      along with 3.6 — the edit flows still write items until this rung.
4. **Text companion.** New capability, built only once the model beneath it
   is stable, in three rungs: productionize the content pipeline (API
   structured output, not the prototype's claude-CLI) and run it
   *out-of-band* first, landing its output as ordinary curated word_lists —
   real chapter decks ship before any new schema; then add
   `texts`/`chapters` and first-occurrence positions so runs become
   first-class; then the chapter-study UX (leveling, cross-chapter dedup
   surfaced to the reader).

One discipline the in-place path demands, restated: every backfill is
global — a bug touches all language decks at once — so each rung ships with
a dry-run report (the 3.1 tooling) before the write.

## Open questions

- **Writing skill grain**: sense vs. entry vs. character (see wrinkle above).
- **Missed-words / tap-to-collect lists**: per-user dynamic word_lists (kind:
  missed?) — mechanism sketched, not designed.
- **Word_list governance**: who may edit a system list vs. a user list referenced
  by others' decks; deletion of a referenced list (likely just blocked, or
  soft-hidden from the owner, while references exist). More broadly, what a user may
  modify at all: current stance is selections yes, senses/glosses no — whether
  sense-level edit proposals ever earn a place is open.
- **Per-user gloss overrides**: parked. Gloss wording is the one fork-era freedom
  this model drops, and the Basic-deck escape hatch prices it at the entire
  language machinery (readings, fuzzy find, per-sense progress). Candidate
  design: (user, sense, wording) rows that change only that user's card display
  and grading acceptance — canonical senses, memberships, and progress untouched;
  a personal-mnemonic layer, and a signal source for edit proposals. Nothing in
  the schema blocks adding it later.
- **Gloss language**: glosses are English today; multi-gloss-language support
  would hang off senses later.
- **In-app reader**: chapters retain their source bodies, so a reader is
  storage-ready, but the feature itself — display, and what "hosted" means for
  copyright and visibility — is undesigned. (An earlier `texts.hosted` flag was
  dropped as machinery-free.)
- **Occurrence evidence**: quoted-from-text sentences were cut from
  sense_examples — they belong to sense × text occurrence and inherit the text's
  copyright status. Two future consumers would revive them: auditing an LLM
  gloss against the sentence that produced it, and chapter pre-study context
  ("the sentence where chapter 3 uses this word"). Design when one exists.
