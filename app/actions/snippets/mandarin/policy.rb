# frozen_string_literal: true

module Snippets
  module Mandarin
    # What counts as a card, shared by the prompts that ask about a snippet.
    # Settled against hand-reviewed answer keys; the examples are deliberately
    # not taken from the texts the rules were tested on.
    module Policy
      SEGMENTATION = <<~TEXT
        Segmentation rules. The base rule: a word is a unit whose meaning a
        learner could not get from its parts. Keep a word whole when it means
        more than, or something other than, its parts put together (心碎,
        有趣, 只是, 看到, 民主主义, 公共汽车 "bus"). Split a combination whose
        parts, each glossed on its own, already say what the whole means
        (除夕夜 → 除夕, 夜; 空气质量 → 空气, 质量; 等地 → 等, 地). When unsure,
        keep a word a standard dictionary lists whole. A word only counts
        when it carries its own meaning here: 东西 is "thing", but in 东西两边
        it is 东 "east" + 西 "west". The fixed patterns below apply either
        way.
        1. Numbers: Arabic digits stay one token. Chinese numerals split into
           single characters (二十五 → 二, 十, 五; 六百多 → 六, 百, 多). A word
           that merely contains a numeral is a word (四季, 五金).
        2. Dates and times split into number and unit (十八世纪 → 十, 八, 世纪;
           十一月 → 十, 一, 月; 2008年 → 2008, 年; 初一 → 初, 一). Era names
           (贞观, 康熙) are words.
        3. A number and its measure word split, even when a dictionary lists
           the pair (一本 → 一, 本; 五人 → 五, 人), unless together they mean
           more than the number times the unit (一定, 一些, 一样, 一直).
        4. An established idiom (成语) stays whole (一帆风顺, 画蛇添足,
           自相矛盾). One-off phrases, quotations and parallel sayings split
           into their words, which may be two-character words, not always
           single characters (学而时习之 → 学, 而, 时, 习, 之; 床前明月光 → 床,
           前, 明月, 光; 无灾无祸 → 无, 灾, 无, 祸).
        5. Personal names, places and era names stay whole (李白, 杭州). So
           does a well-known name or title (红楼梦, 史记, 唐太宗, 唐诗三百首,
           春节联欢晚会). A title that only describes its subject splits into
           its words (中国古代史研究 → 中国, 古代史, 研究; 燕王 → 燕, 王), as do
           an unlisted grouping of surnames (李杜 → 李, 杜) and a surname with
           氏 or 姓 (王氏 → 王, 氏).
        6. The grammatical pieces 们, 于 / 於, 之, 中 ("in"), 所, 者 always
           split off (出生于 → 出生, 于; 水中 → 水, 中; 老师们 → 老师, 们),
           unless the whole has a meaning of its own (位于, 于是, 之后, 总之).
           Verb results follow the base rule: whole when the pair means more
           than verb plus result (看见, 学会), split when the result just adds
           its usual meaning (炒熟 → 炒, 熟; 剪短 → 剪, 短; 贴上 → 贴, 上).
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
        - A gloss is what a reader needs in place of the word: usually one to
          four words. A name is glossed by its usual English name alone
          (Mencius, Tsuen Wan, Aojiu Festival), with no note on what it is.
          Leave out explanations of use, customs or grammar, a literal
          translation alongside the meaning, and the word's pinyin.
      TEXT

      FUNCTION_WORDS = <<~TEXT
        Function words (particles, prepositions, conjunctions and adverbs) are
        where a listed sense most often looks right and is not. A listed sense
        fits a function word only if it names the role the word plays in this
        sentence: a preposition introducing a place or a time is "in", "at"
        or "during", not a verb meaning "to be located"; an adverb may mean
        "already", "only then" or "mostly" rather than the commonest gloss; a
        conjunction may mark contrast ("as for", "but") rather than sequence
        ("then"); 以 in 以X为Y and its short forms (以X最…, 以X较为…) marks the
        thing taken as Y or singled out: "to take as", not "by means of". When
        no listed sense names the role, propose a new one.
        The same holds for a direction or result word split off after a verb
        (拿起 → 拿, 起; 跑出 → 跑, 出; 写完 → 写, 完): it names what it adds to
        the verb ("up", "out", "finished"), not its meaning as a verb on its
        own ("to rise", "to go out"). Gloss it in plain English, with no
        grammar label ("up", not "up (direction complement)").
      TEXT
    end
  end
end
