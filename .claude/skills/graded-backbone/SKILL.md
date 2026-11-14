---
name: graded-backbone
description: Write a "backbone" for a language in Flash — one literary work retold at every level (HSK 1 up to a modern retelling and the original), each level checked against the level's word list, reviewed for natural writing by a fresh reviewer, then added to the app as a source per level. Use when the user wants to write, extend, check or add graded versions of a text (西游记 was the first), or plan a backbone for another language.
---

# Graded backbone

A backbone is one literary work retold at each level, then a modern
retelling, then the original, so a learner climbs one story from beginner to
the real book. Learners study each text's own words as cards; the texts lead
them through the levels. Side texts fill gaps later. 西游记 chapters 1–7 were
the first (sources 17–25: 西游记 HSK 1 … HSK 7–9, 现代版, 原著).

## Working with the user

- **The user doesn't read the target language well enough to judge it.**
  Every draft goes to a fresh reviewer agent that hasn't seen the drafting,
  and the user checks story consistency through plain English translations
  of a few chapters at a few levels.
- Decide with the user, one question at a time: the work and its span, the
  levels, target lengths, titles, licenses, and how names are glossed.
- No app code without discussing it first. The tooling so far has been
  scratch scripts in `tmp/reading_levels/` (see Tools).

## Levels and lengths

Nine versions: HSK 1–6, one HSK 7–9, a modern retelling and the original.
Each level is roughly two-thirds the length of the one above. For 西游记
(per chapter of ~5,600 characters): modern ~4,200, HSK 7–9 ~2,000, 6 ~1,300,
5 ~900, 4 ~650, 3 ~500, 2 ~350, 1 ~200. Lower levels are shorter so a
beginner can finish the story.

Later backbones (O Alienista, at A1–C2) set no length: vocabulary is the
rule, and each level's guidelines say how much of the story it keeps (every
beat and the asides at the top, only the events the chapter turns on at the
bottom). The writer ignored word targets anyway.

**Headings:** the original keeps its real chapter titles (回目), translated
literally; modern to HSK 4 use 第N回 plus a short title (石猴出世); HSK 3–1 a
shorter one within level (石猴). The chapter number links the versions.

## Writing top-down

1. Fetch the original (Wikisource's `/zh-hans/` path gives simplified;
   strip the header table, footnotes and license footer, and keep the 回目).
2. Write the modern retelling from the original: every plot beat, name and
   number kept, most poems dropped.
3. Write each level from the one above (HSK 7–9 from modern, 6 from 7–9, …),
   so names and wording stay the same up the ladder. Use chapter 1 at this
   level and the level above as the example of how much to simplify.
4. Do one chapter through every level first, to settle lengths, story words
   and tone before writing the rest.

## Vocabulary rules

- **Check every draft** against the HSK 3.0 word lists in the compendium
  ("Mandarin HSK3.0 Level 1" … "Level 7"), splitting the text into words and
  flagging any above the level. Rerun the check after applying review fixes:
  reviewers' suggestions often bring back harder words.
- **Names pass at every level:** people, places, titles and named magic items
  (花果山, 太上老君, 金箍棒, 筋斗云), plus a few recurring story elements
  (魔王, 咒语, 毫毛, 桃子).
- **Story words belong to one level only.** A plot-essential thing with no
  level-word way to say it may be kept and declared, at most three per
  chapter, and never one with a simpler way to say it (鸟 for 鹞鹰, 半夜 for
  三更). Story words must not flow down to lower levels: the first run let
  them, and HSK 7–9's ~100 declared words (俸禄, 鹞鹰…) passed at HSK 1–3.
- **Grammar words at HSK 1–2.** Avoiding common HSK 3 grammar words made
  wrong Chinese (变了一只麻雀 instead of 变成), so these are allowed at
  HSK 1–2: 变成 把 又 带 最后 以后 可是 就 怕 学会; at HSK 1 also 飞 远 出来
  跳出 过; at HSK 2 also 放 生气; 打不过 at HSK 1–3. One slightly-above-level
  word beats wrong Chinese.
- **Checker false alarms** from greedy longest-match splitting: 一个人 read as
  个人, 天上 for 天 + 上, 很多年来, 打不过 as 不过, 才能 ("only then can")
  as the noun, 一下子. A better checker picks the split with the fewest flags.

## The review loop

Per draft: write → check vocabulary → revise until clean (up to three
rounds) → fresh review → apply fixes within level → check again. A REWORK
verdict gets a second review. **Always end on a review**: the first script
applied the last review's fixes but never re-reviewed them, so six drafts
looked worse than they were.

The reviewer prompt, with {TEXT}, {SOURCE} and {LEVEL} filled in:

> You are reviewing a graded-reader retelling of one chapter of 西游记 for
> learners of Mandarin. Read it as an experienced native-speaking teacher and
> editor of graded readers would. The vocabulary has already been checked
> mechanically against the HSK 3.0 lists, so don't police individual words
> against the lists. Names and a few story words are allowed on purpose.
> Check: (1) naturalness within the level's limits: stiff phrasing,
> translationese, wrong collocations or measure words, monotonous rhythm;
> (2) grammar for the level; (3) errors: grammar, characters, full-width
> punctuation; (4) story: anything lost or garbled that makes it confusing
> compared with the fuller version. Report a verdict (PASS or REWORK) and a
> numbered list of real problems, each with the quote, category, why (in
> English), and a replacement that stays as simple as the text around it.

For the modern version the reviewer checks fidelity to the original instead
(every plot beat, name and number), and for register slips.

The writer's rules (as a system prompt for each draft): simplified
characters and full-width punctuation; the given heading line first; stay
within the level's words, names and declared story words; grammar and
sentence length to suit the level; natural Mandarin a native teacher would
write, varying sentence openings; **never cut a setup that a later line
depends on** (who someone is, why something happens, who is speaking); end
with the chapter's closing teaser line.

## Lessons from 西游记

- Below HSK 4, most review problems were **story gaps from cutting setup
  lines**, not bad Chinese: a woodcutter denying he's an immortal when no one
  called him one; refusing teachings never offered; a dream that changes
  nothing without the "but".
- Reviewers caught real fidelity slips in the modern version (孙 = 子 + 系
  only works in traditional 孫) and misreadings of classical phrases
  (自揣自摸 "pondered", not "patted himself"). Use them on every version.
- At HSK 1 the densest chapters (the shape-changing chase, the bet with the
  Buddha) need the most care; check that the key event is actually stated.
- Writing in-session gave control while the method settled; a script with
  the same prompts did the remaining 40 drafts. Running three chapters at a
  time worked on the subscription.

## Into the app

1. One source per version, one snippet per chapter, owned by the local
   admin: `Backbones::Load` (see Tools) makes them from `backbone.yml` and
   `headings.yml`. 西游记 was set up by hand and used titles 西游记 HSK N / HSK 7–9 / 现代版 / 原著
   (Latin "HSK N" gets no cards), author 吴承恩, CC BY-SA for the
   retellings, public domain plus the Wikisource link for the original.
   Titles must be unique: the Wikipedia summary became 西游记 故事大纲.
2. Process, review, finish and push with the compendium-review skill,
   **bottom-up**: each level reuses the senses made below it.
3. Name glosses decided with the user: gloss a title by its meaning, not by
   another translator's name or plain pinyin — 太上老君 "Supreme Lord Lao",
   太白金星 "Great White Venus" (short form 金星 "Venus"), 如来 "Tathagata".

## Tools

A backbone's settings, headings and texts are written in
`drafts/backbones/<name>/`, which git ignores; once loaded, the database
holds the texts (see Graded Backbones in AGENTS.md). Both tools cover
Portuguese so far; 西游记 was written with scratch scripts.

- **Check** texts with
  `bin/rails "call[Backbones::CheckReport,<name>,<level>,<chapter>]"`
  (leave the level or chapter blank for all): the words above the level by
  base form, with the lowest level that lists each.
- **Write** the missing texts with
  `bin/rails "call[Backbones::Run,<name>,<chapter>,<level>]"`. It runs the
  loop above for each text, top-down, and ends with the headings it wrote,
  for the user to look over. It is long (about ten minutes a text), so run
  it in the background or overnight; a usage-limit stop loses only the text
  in hand.
- **Settle a stopped draft** from its `.trouble.md`: fix the `.draft.txt`
  (check it, and give it a fresh review if the fix is more than a word or
  two), save it as the text, put its heading in `headings.yml`, and delete
  both files; the next run carries on below it.
- **Level guidelines** live in `backbone.yml`, so tighten them there when the
  reviews keep raising the same thing, rather than fixing every draft.

- **Load** the written chapters into the app with
  `bin/rails "call[Backbones::Load,<name>,<username>]"` (the local admin):
  a source per version and a snippet per chapter, in reading order, headed
  by the chapter's numeral and title. Run it again as chapters are written;
  it adds only the next ones. Once a chapter is loaded the database owns its
  text, so fix it there, not in the drafts.

Still to build: Mandarin for the checker (a title with a meaning should be
glossed by its meaning, which `Snippets::Mandarin::Policy` doesn't yet say).
