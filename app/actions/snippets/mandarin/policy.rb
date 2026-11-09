# frozen_string_literal: true

module Snippets
  module Mandarin
    # What counts as a card, shared by the prompts that ask about a snippet.
    # Settled against hand-reviewed answer keys; the examples are deliberately
    # not taken from the texts the rules were tested on.
    module Policy
      SEGMENTATION = <<~TEXT
        Segmentation rules. The base rule: split a word into the smallest
        pieces that each carry a natural meaning of their own in this
        sentence, down to single characters where that holds (很多 → 很, 多;
        山洞 → 山, 洞; 大声 → 大, 声). A piece's meaning is natural when an
        ordinary English word or suffix says what that character means (大
        "big", 性 "-ity"), not only a grammatical role ("successfully").
        Keep a word whole when:
        - it is a curriculum (HSK) word. The curriculum words a sentence
          writes are listed with it as curriculum_words; keep one whole
          wherever it is used as that word;
        - a piece would only get a grammatical gloss: direction words after
          a verb (跳出来 → 跳, 出来; 进去, 回来) and results such as 看到;
        - its pieces mislead, because their own meanings don't add up to
          the word's (东西 "thing", 金星 "Venus", 筋斗 "somersault"), it
          borrows a sound (阎王, 兜率宫, 释迦牟尼), or it is a pun (弼马温).
        A word only counts when it carries its own meaning here: 东西 is
        "thing", but in 东西两边 it is 东 "east" + 西 "west". The fixed
        patterns below apply either way.
        1. Numbers: Arabic digits stay one token. Chinese numerals split into
           single characters (二十五 → 二, 十, 五; 六百多 → 六, 百, 多). A
           numbered set splits like any counted noun (二十八宿 → 二, 十, 八,
           宿; 五行 → 五, 行).
        2. Dates and times split into number and unit (十八世纪 → 十, 八, 世纪;
           2008年 → 2008, 年; 初一 → 初, 一). Era names (贞观, 康熙) are words.
        3. A number and its measure word split (一本 → 一, 本; 五人 → 五, 人),
           unless together they mean more than the number times the unit
           (一个人 where it means "alone", 一个个 "every one of them").
        4. An idiom splits like any phrase, so the reader sees its image
           (天罗地网 → 天, 罗, 地, 网); a piece that is a curriculum word or
           would mislead stays whole inside it. Quotations split the same
           way (学而时习之 → 学, 而, 时, 习, 之).
        5. Personal names stay whole (李白, 孙悟空, 哪吒). Titles and other
           names split into their pieces like any description, even where a
           piece is literary (太上老君 → 太, 上, 老, 君; 花果山 → 花, 果, 山;
           瑶池 → 瑶, 池), unless their pieces mislead (金星, 阎王, 弼马温).
        6. The grammatical pieces 们, 于 / 於, 之, 中 ("in"), 所, 者 split
           off (出生于 → 出生, 于; 水中 → 水, 中; 老师们 → 老师, 们), and so
           do aspect particles (了, 着 / 著, 过 / 過) and structural
           particles (的, 地, 得) (花了 → 花, 了; 看着 → 看, 着).
        7. A verb's result splits when it adds its usual meaning (炒熟 → 炒,
           熟; 剪短 → 剪, 短; 贴上 → 贴, 上) and stays with the verb when it
           has no natural gloss of its own (看到).
        8. A suffix splits off like 们, glossed by the English suffix or word
           that matches (科学家 → 科学, 家 "-ist"; 可能性 → 可能, 性 "-ity").
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
        - Prefer a character's core meaning when it still reads (大 "big" in
          大笑, not "loudly"). A suffix split off is glossed by the English
          suffix that matches ("-ness", "-ize", "-ist").
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
