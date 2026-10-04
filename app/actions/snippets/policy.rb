# frozen_string_literal: true

module Snippets
  # What counts as a card, shared by the prompts that ask about a snippet.
  # Settled against hand-reviewed answer keys; the examples are deliberately
  # not taken from the texts the rules were tested on.
  module Policy
    SEGMENTATION = <<~TEXT
      Segmentation rules. The base rule: a word is one a standard dictionary
      lists. Keep every listed word whole (心碎, 有趣, 只是, 看到, 民主主义,
      公共汽车), except where one of the fixed patterns below splits it. A
      combination no dictionary lists splits into dictionary words, unless
      it is a personal name, place or era name. A listed word only counts
      when it carries its listed meaning here: 东西 is "thing", but in
      东西两边 it is 东 "east" + 西 "west".
      1. Numbers: Arabic digits stay one token. Chinese numerals split into
         single characters (二十五 → 二, 十, 五; 六百多 → 六, 百, 多). A word
         that merely contains a numeral is a word (四季, 五金).
      2. Dates and times split into number and unit (十八世纪 → 十, 八, 世纪;
         十一月 → 十, 一, 月; 2008年 → 2008, 年). Era names (贞观, 康熙) are
         words.
      3. A number and its measure word split, even when a dictionary lists
         the pair (一本 → 一, 本; 五人 → 五, 人), unless together they mean
         more than the number times the unit (一定, 一些, 一样, 一直).
      4. An idiom a standard dictionary lists stays whole (一帆风顺, 画蛇添足,
         自相矛盾). One-off classical phrases and quotations split into
         their dictionary words, which may be two-character words, not
         always single characters (学而时习之 → 学, 而, 时, 习, 之; 床前明月光
         → 床, 前, 明月, 光).
      5. Personal names, places and era names stay whole (李白, 杭州). So
         does any name or title a dictionary lists (红楼梦, 史记, 唐太宗,
         唐诗三百首). An unlisted title or descriptive title splits into its
         words (中国古代史研究 → 中国, 古代史, 研究; 燕王 → 燕, 王), as do an
         unlisted grouping of surnames (李杜 → 李, 杜) and a surname with 氏
         or 姓 (王氏 → 王, 氏).
      6. The grammatical pieces 们, 于 / 於, 之, 中 ("in"), 所, 者 always
         split off (出生于 → 出生, 于; 水中 → 水, 中; 老师们 → 老师, 们),
         unless the whole is a listed word in its own right (位于, 于是,
         之后, 总之). Verb results follow the base rule: whole when listed
         (看见, 学会, 煮熟), split when not (炒熟 → 炒, 熟; 剪短 → 剪, 短).
         Suffixes that make a new word stay attached (科学家, 美国人, 营业员,
         可能性).
      Characters that are not Chinese (kana, Latin letters) are never part
      of a word with Chinese characters.
    TEXT

    READING = <<~TEXT
      Reading and gloss rules:
      - Write the tone changes of 一 and 不 as spoken (不错 búcuò, 一定
        yídìng, 一样 yíyàng). 一 keeps yī when counted on its own, as an
        ordinal, or at the end of a word (第一, 统一). A 一 or 不 that is a
        token of its own reads yī / bù. Never write the third-tone change.
      - Gloss what is written, as it is used in this sentence, even where
        the text has a typo or a stray character. Never gloss the word the
        author probably meant instead.
    TEXT

    FUNCTION_WORDS = <<~TEXT
      Function words (particles, prepositions, conjunctions and adverbs) are
      where a listed sense most often looks right and is not. A listed sense
      fits a function word only if it names the role the word plays in this
      sentence: a preposition introducing a place or a time is "in", "at"
      or "during", not a verb meaning "to be located"; an adverb may mean
      "already", "only then" or "mostly" rather than the commonest gloss; a
      conjunction may mark contrast ("as for", "but") rather than sequence
      ("then"). When no listed sense names the role, propose a new one.
    TEXT
  end
end
