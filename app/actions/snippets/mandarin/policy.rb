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
        parts, each glossed on its own, already say what the whole means,
        even one a dictionary lists (除夕夜 → 除夕, 夜; 空气质量 → 空气,
        质量; 大雨 → 大, 雨; 交给 → 交, 给; 小猫 → 小, 猫). Exceptions kept
        whole: 很多, 天上, 地上, 山洞, 大声, 家里, 这时, 整天, 有人, 不能 (but
        能不能 → 能, 不, 能), and the direction words 进去, 出来,
        进来, 出去, 下来, 上来, 下去, 过去, 过来, 回去, 回来, 起来 after a
        verb (跳出来 → 跳, 出来). A word only counts when it carries its own
        meaning here: 东西 is "thing", but in 东西两边 it is 东 "east" + 西
        "west". The fixed patterns below apply either way.
        1. Numbers: Arabic digits stay one token. Chinese numerals split into
           single characters (二十五 → 二, 十, 五; 六百多 → 六, 百, 多). A word
           that merely contains a numeral is a word (四季, 五金).
        2. Dates and times split into number and unit (十八世纪 → 十, 八, 世纪;
           十一月 → 十, 一, 月; 2008年 → 2008, 年; 初一 → 初, 一). Era names
           (贞观, 康熙) are words.
        3. A number and its measure word split, even when a dictionary lists
           the pair (一本 → 一, 本; 五人 → 五, 人), unless together they mean
           more than the number times the unit (一定, 一些, 一样, 一直, 一个人
           where it means "alone", and 这个, 那个, 哪个 even before a noun).
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
        6. The grammatical pieces 们, 于 / 於, 之, 中 ("in"), 所, 者 split
           off (出生于 → 出生, 于; 水中 → 水, 中; 老师们 → 老师, 们), and so
           do aspect particles (了, 着 / 著, 过 / 過) and structural
           particles (的, 地, 得) (花了 → 花, 了; 看着 → 看, 着), unless the
           whole has a meaning of its own (位于, 于是, 之后, 总之, 为了, 除了,
           觉得, 目的). Pronouns with 们 stay whole (我们, 你们, 他们, 她们,
           它们, 咱们).
        7. Verb results follow the base rule: whole when the pair means more
           than verb plus result (看见, 学会), and so do the everyday pairs
           来到, 回到, 变成 and 摔倒; split when the result just adds its usual
           meaning (炒熟 → 炒, 熟; 剪短 → 剪, 短; 贴上 → 贴, 上).
        8. Suffixes that make a new word stay attached (科学家, 美国人, 营业员,
           可能性).
        Characters that are not Chinese (kana, Latin letters) are never part
        of a word with Chinese characters, and punctuation is never part of
        a word (《新黑客辞典》 → 《, 新黑客辞典, 》).
      TEXT

      READING = <<~TEXT
        Reading and gloss rules:
        - A reading is pinyin with tone marks and its syllables joined
          (niànshū), capitalised for a name. A sense pronounced like a
          listed one copies its reading exactly.
        - Write the tone changes of 一 and 不 as spoken (不错 búcuò, 一定
          yídìng, 一样 yíyàng). 一 keeps yī when counted on its own, as an
          ordinal, or at the end of a word (第一, 统一). A 一 or 不 that is a
          token of its own reads yī / bù. Never write the third-tone change.
        - 地方 "place" is dìfang; dìfāng is "local, regional".
        - Gloss what is written, as it is used in this sentence, even where
          the text has a typo or a stray character. Never gloss the word the
          author probably meant instead.
        - A gloss is what a reader needs in place of the word: usually one to
          four words, for this one meaning. A name is glossed by the usual
          English name of what it names in this text (Mencius, Tsuen Wan; 新
          in 新马 is Singapore), with no note on what it is. A function word
          English has no word for is glossed by its job ("possessive
          particle").
        - Leave out hanzi, pinyin, cross-references, other meanings,
          explanations of use, customs or grammar, and a literal translation
          alongside the meaning.
        - A listed sense fits only if its whole gloss could stand in for the
          word here; one that strings together different meanings (鲁 "rash;
          crude; short name for Shandong") never does, so propose a sense with
          the one meaning needed. Synonyms (杯 "cup; glass") are fine.
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
        thing taken as Y or singled out: "to take as", not "by means of".
        The same holds for a direction or result word split off after a verb
        (拿起 → 拿, 起; 跑出 → 跑, 出; 写完 → 写, 完): it names what it adds to
        the verb ("up", "out", "finished"), not its meaning as a verb on its
        own ("to rise", "to go out"). Gloss it in plain English, with no
        grammar label ("up", not "up (direction complement)").
        The same holds for pronouns and 一: 他 is "him" as an object and
        "his" before 的, not "he", and 一 right before a verb (一看) is "as
        soon as", not "a bit". 太 … 了 is "too", not "very". 去 or
        来 after the place a verb heads for marks direction ("that way",
        "this way"), not "to go" / "to come".
      TEXT
    end
  end
end
