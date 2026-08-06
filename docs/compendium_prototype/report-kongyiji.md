# kongyiji — compendium pipeline prototype report

Text: Lu Xun's short story 孔乙己 (1919, modern vernacular), simplified, 1382 Han tokens, 605 studyable words.
Lexicon stand-in: HSK 1–7 deck (flash-csvs). Sonnet proposes, Opus confirms.

## Coverage

| bucket | unique words | tokens | token share |
|---|---|---|---|
| in lexicon (HSK) | 364 | 976 | 70.6% |
| new, CEDICT-grounded | 161 | 286 | 20.7% |
| not in CEDICT | 80 | 88 | 6.4% |
| pre-split artifacts (counts fan to parts) | 57 | 80 | 5.8% |

HSK words by level: L1: 98, L2: 44, L3: 44, L4: 56, L5: 40, L6: 34, L7: 48

## Pre-split (deterministic, verified)

57 artifact tokens split by rule: number: 31, suffix: 22, redup: 3, a-not-a: 1.

**number**: 四文→文, 一碗→碗, 二十多年→年, 每碗→碗, 十文→文, 多花→花, 一文→文, 一碟→碟, 十二岁→岁, 一副→副, 几声→声, 一部→部, 十多年→年, 一到→到, 两碗→碗, 九文→文, 一笔→笔, 一回→回, 两个→个, 四样→样, 几回→回, 一人→人, 一颗→颗, 一群→群, 一天→天, 两三天→天, 十九个→个, 一望→望, 一件→件, 两腿→腿, 一九一九年→年

**suffix**: 柜外→柜+外, 看着→看+着, 看过→看+过, 底里→底+里, 夹些→夹+些, 取下→取+下, 脸上→脸+上, 吊着→吊+着, 额上→额+上, 愈过→愈+过, 做些→做+些, 店里→店+里, 字么→字+么, 笼上→笼+上, 我么→我+么, 回过→回+过, 写罢→写+罢, 记着→记+着, 柜上→柜+上, 钱呢→钱+呢, 盘着→盘+着, 肩上→肩+上

**redup**: 热热→热, 条条→条, 懒懒→懒

**a-not-a**: 多不多→多

## Phase A — match step (existing cards)

308/364 covered by the existing gloss. Of 56 proposed new senses, Opus confirmed 32, rejected 24.

| word | existing gloss | proposed new sense | confirm | sentence |
|---|---|---|---|---|
| 散 | loose; scattered; to come loose; to scatter; to disperse | to finish work for the day, knock off work | ok | 做工的人，傍午傍晚散了工，每每花四文铜钱，买一碗酒—… |
| 到 | to arrive | to reach/rise to a certain point or amount (used as a verb complement, e.g. 涨到 "rise to") | reject|complement use "reach (an amount)" is a grammatical extension of "arrive" | 做工的人，傍午傍晚散了工，每每花四文铜钱，买一碗酒—… |
| 文 | writing; language; culture | wen (a unit of copper cash currency) | ok | 倘肯多花一文，便可以买一碟盐煮笋，或者茴香豆，做下酒… |
| 那 | that; those | then; in that case (sentence-initial conjunction, not the demonstrative) | ok | 倘肯多花一文，便可以买一碟盐煮笋，或者茴香豆，做下酒… |
| 一样 | the same; like | one kind/type (measure word for a dish/item, not "same as") | ok | 倘肯多花一文，便可以买一碟盐煮笋，或者茴香豆，做下酒… |
| 多 | many; much; more; a lot of | mostly; for the most part (adverb before a verb, not "many/much") | ok | 倘肯多花一文，便可以买一碟盐煮笋，或者茴香豆，做下酒… |
| 帮 | to help; to assist | group; gang; crowd (a set of people, not "to help") | ok | 倘肯多花一文，便可以买一碟盐煮笋，或者茴香豆，做下酒… |
| 房子 | house; apartment | room (an inner room within a building, not a whole house) | reject|"room vs house" is contextual narrowing of the taught meaning | 只有穿长衫的，才踱进店面隔壁的房子里，要酒要菜，慢慢… |
| 起 | to rise | starting from; since (marks a starting point, used with 从...起, not physical "rising") | ok | 我从十二岁起，便在镇口的咸亨酒店里当伙计，掌柜说，样… |
| 亲 | close; to kiss | personally; in person (adverb before a verb) | ok | 他们往往要亲眼看着黄酒从坛子里舀出，看过壶子底里有水… |
| 将 | will; shall | marks the object of a verb (like 把), introducing what is being handled/moved — not the future-tense "will" | ok | 他们往往要亲眼看着黄酒从坛子里舀出，看过壶子底里有水… |
| 为难 | embarrassed; to make things difficult (for someone) | difficult to manage or carry out; troublesome (describing a task/situation, not a person's feelings) | reject|"finding it hard/awkward to do" is already covered by the existing gloss | 他们往往要亲眼看着黄酒从坛子里舀出，看过壶子底里有水… |
| 不得 | must not | cannot; not able to (as a verb complement: V+不得 = "cannot be V-ed", not a prohibition) | ok | 幸亏荐头的情面大，辞退不得，便改为专管温酒的一种无聊… |
| 什么 | what? | any; much (in negative constructions like 没有什么, not the question word "what") | ok | 虽然没有什么失职，但总觉有些单调，有些无聊。 |
| 间 | classifier for rooms | between; among | ok | 青白脸色，皱纹间时常夹些伤痕； |
| 夹 | to press from either side | interspersed among; mixed in with | ok | 青白脸色，皱纹间时常夹些伤痕； |
| 部 | ministry; department; classifier for films, books | classifier for a shock/mass of hair or beard | ok | 一部乱蓬蓬的花白的胡子。 |
| 孔 | aperture; small hole | Kong (a Chinese surname) | ok | 因为他姓孔，别人便从描红纸上的『上大人孔乙己』这半懂… |
| 大人 | adult | honorific title for a person of rank, roughly "your excellency" (archaic, not "adult") | ok | 因为他姓孔，别人便从描红纸上的『上大人孔乙己』这半懂… |
| 的话 | if (coming after a conditional clause) | words; speech (的 here is just an attributive particle attached to 话, not the "if" construction) | reject|segmentation artifact — 的 + 话, not a sense of the word 的话 | 因为他姓孔，别人便从描红纸上的『上大人孔乙己』这半懂… |
| 何 | what | He (a Chinese surname) | ok | 我前天亲眼见你偸了何家的书，吊着打。 |
| 道 | road; way; classifier for rivers, walls, dishes, or questions | said (speech verb introducing a quotation, like "said") | ok | 』孔乙己便涨红了脸，额上的青筋条条绽出，争辩道：『窃… |
| 者 | one who (is) ... | classical function word cited as an example of archaic bookish speech, not used as "one who" | reject|mentioned as a citation of classical speech, not a distinct sense of the word | 』接连便是难懂的话，什么『君子固穷』，什么『者乎』之… |
| 起来 | to stand up; to get up | used after a verb to show an action starting/bursting into being | ok | 』接连便是难懂的话，什么『君子固穷』，什么『者乎』之… |
| 空气 | air | atmosphere; mood; ambiance | reject|figurative extension of "air", transparent from existing gloss | 店内外充满了快活的空气。 |
| 读 | to read; to read aloud | to study; to attend school (as in 读书, receiving education, not literally reading aloud) | reject|读书 "study" reads naturally from taught "to read" | 听人家背地里谈论，孔乙己原来也读过书，但终于没有进学… |
| 弄 | to do; to handle; to mess with | to end up (in a situation); to get to the point of — as in 弄到, "it got to where..." | reject|taught "do/make" plus resultative 到; grammatical variation | 于是愈过愈穷，弄到将要讨饭了。 |
| 笔 | pen | classifier for a style of handwriting/brushwork | ok | 幸而写得一笔好字，便替人家钞钞书，换一碗饭吃。 |
| 叫 | to call; to be called; to shout | to tell/have someone do something; to hire someone for a task | ok | 如是几次，叫他钞书的人也没有了。 |
| 偶然 | incidental; accidental; by chance | occasionally; now and then (frequency, not by chance) | ok | 孔乙己没有法，便免不了偶然做些偸窃的事。 |
| 过半 | over fifty percent | verb suffix marking a completed action ("have done"); here it attaches to the verb "drink," not part of a word meaning "over half" | reject|segmentation error (喝过 + 半碗酒), not a new sense of 过半 | 孔乙己喝过半碗酒，涨红的脸色渐渐复了原，旁人便又问道… |
| 捞 | to fish up | to obtain or get something (often through effort or scheming), figurative extension of "fish up" | reject|figurative extension of "fish up"; understandable from gloss | 他们便接着说道：『你怎的连半个秀才也捞不到呢？ |
| 呢 | (follow-up question particle: what about…?) | particle adding emphasis/rhetorical force to a full question (often with a question word like 怎的), not an elliptical follow-up | ok | 他们便接着说道：『你怎的连半个秀才也捞不到呢？ |
| 一些 | some; a few (quantity of things) | at all; in the least (used with a negative to mean "not ~ at all") | ok | 这回可是全是之乎者也之类，一些不懂了。 |
| 点 | (after a number) o'clock; a bit; o'clock; a bit; to order (food); to tap | to nod (the head), as in 点头 | reject|点头 compound; covered by taught "to tap/touch briefly" | 』我略略点一点头。 |
| 考 | to take an exam; to test | to test/quiz someone with a question | reject|existing gloss already says "to test"; quizzing a person is the same sense | 他说，『读过书，……我便考你一考。 |
| 理会 | to understand; to pay attention to | to acknowledge/respond to someone | reject|covered by "to pay attention to" | 便回过脸去，不再理会。 |
| 等 | to wait (for); etc.; and so on; class; grade | to wait | reject|identical to the taught "to wait (for)" | 孔乙己等了许久，很恳切的说道：『不能写罢？ |
| 来回 | to make a round trip; return journey; back and forth | the character "回" (as in 回字) — repeated/looping shape referenced, not "round trip" | reject|来回 is cited in its ordinary meaning to identify which 回 character; no new sense | 又好笑，又不耐烦，懒懒的答他道：『谁要你教，不是草头… |
| 呀 | ah (used to express surprise) | particle expressing agreement/emphasis (not surprise), like "right!" after a statement | ok | 』孔乙己显出极高兴的样子，将两个指头的长指甲敲着柜台… |
| 回 | to return | the character/word "回" itself, referring to how it's written | reject|autonymous mention of the character, not a distinct sense | ……回字有四样写法，你知道么？ |
| 愈 | the more ... the more | increasingly; more and more (used alone, not in the 愈...愈... "the more...the more" pattern) | reject|same meaning "more", just used without the paired pattern | 』我愈不耐烦了，努着嘴走远。 |
| 一口气 | in one breath; at a stretch | a breath (as the object of 叹, "to heave a sigh") | reject|literal "one breath" is transparent from the taught idiom | 孔乙己刚用指甲蘸了酒，想在柜上写字，见我毫不热心，便… |
| 赶 | to hurry; to catch up with; to drive away | to join in for the fun/excitement of a lively scene | ok | 有几回，邻舍孩子听得笑声，也赶热闹，围住了孔乙己。 |
| 长久 | lasting | for a long time; a long while (adverbial duration, not "lasting" as a static adjective) | reject|adverbial use of the same "long in time" meaning | 有一天，大约是中秋前的两三天，掌柜正在慢慢的结帐，取… |
| 钱 | money | a monetary unit (a copper coin/cash), used after a number to count small sums, not money in the abstract | reject|countable "coins" is a grammatical variation of the taught "money", not a distinct sense | 还欠十九个钱呢！ |
| 打折 | to give a discount | to break (a bone/limb) by beating | ok | ……他打折了腿了。 |
| 丁 | small cube (of food); male adult; fourth (in a series) | surname Ding | ok | 这一回，是自己发昏，竟偸到丁举人家里去了。 |
| 半夜 | midnight | a stretch of night (as in 大半夜, "a good part of the night"), not specifically midnight | ok | 先写服辩，后来是打，打了大半夜，再打折了腿。 |
| 再 | again | then; next in a sequence of actions, not repetition of an action | reject|same verb 打 recurs, so the taught "again" reads naturally here; sequential "then" is a nuance | 先写服辩，后来是打，打了大半夜，再打折了腿。 |
| 着火 | to catch fire | by/near a fire for warmth (as in 靠着火, "leaning by the fire"), not the compound verb "catch fire" | reject|segmentation artifact — the sentence is 靠着 + 火, so 着火 isn't the word being used | 我整天的靠着火，也须穿上棉袄了。 |
| 不成 | won't do; (question particle: can that be?) | in a sorry/wretched state; looking a mess | reject|the "sorry state" meaning belongs to the idiom 不成样子; 不成 itself is just "not form/constitute" | 他脸上黑而且瘦，已经不成样子； |
| 盘 | classifier for dishes; classifier for board games | to coil or cross (the legs), as in sitting cross-legged | ok | 穿一件破夹袄，盘着两腿，下面垫一个蒲包，用草绳在肩上… |
| 要好 | on good terms; striving for self-improvement | (of quality) must be good; needs to be good — 要 "must" + 好 "good," not the compound meaning "on good terms" | reject|not the compound 要好 at all — 要 + 好 spans a word boundary, so it isn't a new sense of this word | 这一回是现钱，酒要好。 |
| 打断 | to interrupt | to break (a bone or limb) | ok | 要是不偸，怎么会打断腿？ |
| 摸 | to touch; to stroke | to feel around for and pull out (e.g. from a pocket) | ok | 他从破衣袋里摸出四文大钱，放在我手里，见他满手是泥，… |

## Phase B — new words glossed against CEDICT (16 fixed by confirm)

### word (155)

| word | verdict | confirm | sentence |
|---|---|---|---|
| 别处 | bié chù / elsewhere, other places | ok | 鲁镇的酒店的格局，是和别处不同的：都是当街一个曲尺形… |
| 当街 | dāng jiē / facing the street; right on the street | ok | 鲁镇的酒店的格局，是和别处不同的：都是当街一个曲尺形… |
| 一个 | yī ge / one (measure word phrase) | ok | 鲁镇的酒店的格局，是和别处不同的：都是当街一个曲尺形… |
| 柜 | guì / counter/cabinet — here short for 柜台, the bar counter | ok | 鲁镇的酒店的格局，是和别处不同的：都是当街一个曲尺形… |
| 热水 | rè shuǐ / hot water | ok | 鲁镇的酒店的格局，是和别处不同的：都是当街一个曲尺形… |
| 温酒 | wēn jiǔ / to warm wine before serving | ok | 鲁镇的酒店的格局，是和别处不同的：都是当街一个曲尺形… |
| 做工 | zuò gōng / to do manual/physical labor | ok | 做工的人，傍午傍晚散了工，每每花四文铜钱，买一碗酒—… |
| 傍午 | bàng wǔ / around noon | ok | 做工的人，傍午傍晚散了工，每每花四文铜钱，买一碗酒—… |
| 工 | gōng / work; a work shift | ok | 做工的人，傍午傍晚散了工，每每花四文铜钱，买一碗酒—… |
| 每每 | měi měi / often | ok | 做工的人，傍午傍晚散了工，每每花四文铜钱，买一碗酒—… |
| 铜钱 | tóng qián / copper coin | ok | 做工的人，傍午傍晚散了工，每每花四文铜钱，买一碗酒—… |
| 笋 | sǔn / bamboo shoot | ok | 倘肯多花一文，便可以买一碟盐煮笋，或者茴香豆，做下酒… |
| 茴香豆 | huí xiāng dòu / fennel-flavored beans, a Shaoxing snack | fix|word|huí xiāng dòu|anise-flavored fava beans, a Shaoxing snack | 倘肯多花一文，便可以买一碟盐煮笋，或者茴香豆，做下酒… |
| 下酒 | xià jiǔ / to go with alcohol, as a drinking snack | ok | 倘肯多花一文，便可以买一碟盐煮笋，或者茴香豆，做下酒… |
| 物 | wù / thing (bound form) | ok | 倘肯多花一文，便可以买一碟盐煮笋，或者茴香豆，做下酒… |
| 十几 | shí jǐ / a dozen or so, more than ten | ok | 倘肯多花一文，便可以买一碟盐煮笋，或者茴香豆，做下酒… |
| 荤菜 | hūn cài / meat dish | ok | 倘肯多花一文，便可以买一碟盐煮笋，或者茴香豆，做下酒… |
| 短衣 | duǎn yī / short jacket, worn by laborers | ok | 倘肯多花一文，便可以买一碟盐煮笋，或者茴香豆，做下酒… |
| 大抵 | dà dǐ / generally, for the most part | ok | 倘肯多花一文，便可以买一碟盐煮笋，或者茴香豆，做下酒… |
| 长衫 | cháng shān / long gown (traditional robe marking scholar/gentry status) | ok | 只有穿长衫的，才踱进店面隔壁的房子里，要酒要菜，慢慢… |
| 踱 | duó / to pace, to stroll | ok | 只有穿长衫的，才踱进店面隔壁的房子里，要酒要菜，慢慢… |
| 店面 | diàn miàn / shop front, storefront | ok | 只有穿长衫的，才踱进店面隔壁的房子里，要酒要菜，慢慢… |
| 慢慢 | màn màn / slowly, unhurriedly | ok | 只有穿长衫的，才踱进店面隔壁的房子里，要酒要菜，慢慢… |
| 伙计 | huǒ ji / shop assistant, waiter | ok | 我从十二岁起，便在镇口的咸亨酒店里当伙计，掌柜说，样… |
| 掌柜 | zhǎng guì / shopkeeper, tavern owner | ok | 我从十二岁起，便在镇口的咸亨酒店里当伙计，掌柜说，样… |
| 儍 | shǎ / foolish, silly, dim-witted | ok | 我从十二岁起，便在镇口的咸亨酒店里当伙计，掌柜说，样… |
| 不了 | bù liǎo / unable to (do something), can't manage to | ok | 我从十二岁起，便在镇口的咸亨酒店里当伙计，掌柜说，样… |
| 主顾 | zhǔ gù / customer, patron | ok | 我从十二岁起，便在镇口的咸亨酒店里当伙计，掌柜说，样… |
| 罢 | ba / sentence-final particle softening a suggestion ("so...", "then") | ok | 我从十二岁起，便在镇口的咸亨酒店里当伙计，掌柜说，样… |
| 唠唠叨叨 | láo lao dāo dāo / chattering on, rambling | ok | 外面的短衣主顾，虽然容易说话，但唠唠叨叨缠夹不清的也… |
| 缠夹不清 | chán jiā bù qīng / muddled and confusing, hard to follow (of talk) | ok | 外面的短衣主顾，虽然容易说话，但唠唠叨叨缠夹不清的也… |
| 不少 | bù shǎo / quite a few, no small number | ok | 外面的短衣主顾，虽然容易说话，但唠唠叨叨缠夹不清的也… |
| 黄酒 | huáng jiǔ / yellow rice wine (mulled Shaoxing-style wine) | ok | 他们往往要亲眼看着黄酒从坛子里舀出，看过壶子底里有水… |
| 坛子 | tán zi / earthenware jug, jar | ok | 他们往往要亲眼看着黄酒从坛子里舀出，看过壶子底里有水… |
| 之下 | zhī xià / under, beneath | ok | 他们往往要亲眼看着黄酒从坛子里舀出，看过壶子底里有水… |
| 羼 | chàn / to dilute, water down (here: adulterate the wine with water) | ok | 他们往往要亲眼看着黄酒从坛子里舀出，看过壶子底里有水… |
| 几天 | jǐ tiān / several days, a few days | ok | 所以过了几天，掌柜又说我干不了这事。 |
| 荐头 | jiàn tou / job broker, employment agent (archaic) | ok | 幸亏荐头的情面大，辞退不得，便改为专管温酒的一种无聊… |
| 情面 | qíngmiàn / personal influence/"face"; the weight of someone's good will or connections | ok | 幸亏荐头的情面大，辞退不得，便改为专管温酒的一种无聊… |
| 改为 | gǎi wéi / to change to, switch to (a different role/duty) | ok | 幸亏荐头的情面大，辞退不得，便改为专管温酒的一种无聊… |
| 专管 | zhuān guǎn / to be specifically in charge of, to solely handle | ok | 幸亏荐头的情面大，辞退不得，便改为专管温酒的一种无聊… |
| 一种 | yī zhǒng / a kind of; a sort of | ok | 幸亏荐头的情面大，辞退不得，便改为专管温酒的一种无聊… |
| 整天 | zhěng tiān / all day long | ok | 我从此便整天的站在柜台里，专管我的职务。 |
| 失职 | shī zhí / to neglect one's duty | ok | 虽然没有什么失职，但总觉有些单调，有些无聊。 |
| 脸孔 | liǎn kǒng / face | ok | 掌柜是一副凶脸孔，主顾也没有好声气，教人活泼不得； |
| 声气 | shēng qì / tone of voice; manner of speaking | ok | 掌柜是一副凶脸孔，主顾也没有好声气，教人活泼不得； |
| 喝酒 | hē jiǔ / to drink (alcohol) | ok | 孔乙己是站着喝酒而穿长衫的唯一的人。 |
| 青白 | qīng bái / pale; pallid | ok | 青白脸色，皱纹间时常夹些伤痕； |
| 乱蓬蓬 | luàn péng péng / disheveled; tangled | fix|word|luàn pēng pēng|disheveled; unkempt (hair, beard) | 一部乱蓬蓬的花白的胡子。 |
| 花白 | huā bái / grizzled; graying (hair, beard) | ok | 一部乱蓬蓬的花白的胡子。 |
| 满口 | mǎn kǒu / mouth full of (a certain kind of talk) | ok | 他对人说话，总是满口之乎者也，教人半懂不懂的。 |
| 之乎者也 | zhī hū zhě yě / archaic, pedantic classical-Chinese phrasing | ok | 他对人说话，总是满口之乎者也，教人半懂不懂的。 |
| 半懂不懂 | bàn dǒng bù dǒng / only half understanding | ok | 他对人说话，总是满口之乎者也，教人半懂不懂的。 |
| 描红 | miáo hóng / tracing red-printed characters to practice writing | ok | 因为他姓孔，别人便从描红纸上的『上大人孔乙己』这半懂… |
| 叫道 | jiào dào / to call out; to shout | ok | 孔乙己一到店，所有喝酒的人便都看着他笑，有的叫道：『… |
| 伤疤 | shāng bā / scar | ok | 孔乙己一到店，所有喝酒的人便都看着他笑，有的叫道：『… |
| 温 | wēn / to warm up (wine) | ok | 』他不回答，对柜里说：『温两碗酒，要一碟茴香豆。 |
| 排出 | pái chū / to lay out/count out (coins), one by one | ok | 』便排出九文大钱。 |
| 大钱 | dà qián / old copper coins of a higher denomination | ok | 』便排出九文大钱。 |
| 高声 | gāo shēng / in a loud voice; loudly | ok | 他们又故意的高声嚷道：『你一定又偸了人家的东西了！ |
| 偸 | tōu / to steal | ok | 他们又故意的高声嚷道：『你一定又偸了人家的东西了！ |
| 凭空 | píng kōng / To do something without basis or justification — here, "falsely accuse." | fix|word|píng kōng|out of thin air; without any basis | 』孔乙己睁大眼睛说：『你怎么这样凭空污人清白……』『… |
| 清白 | qīng bái / Innocence; a clean reputation. | ok | 』孔乙己睁大眼睛说：『你怎么这样凭空污人清白……』『… |
| 额 | é / forehead | ok | 』孔乙己便涨红了脸，额上的青筋条条绽出，争辩道：『窃… |
| 青筋 | qīng jīn / Veins (that bulge visibly on the skin, e.g. from anger). | ok | 』孔乙己便涨红了脸，额上的青筋条条绽出，争辩道：『窃… |
| 窃 | qiè / To steal. | ok | 』孔乙己便涨红了脸，额上的青筋条条绽出，争辩道：『窃… |
| 不能 | bù néng / Cannot; must not. | ok | 』孔乙己便涨红了脸，额上的青筋条条绽出，争辩道：『窃… |
| 么 | ma / Question particle placed at the end of a sentence (like "right?"). | ok | ……读书人的事，能算偸么？ |
| 便是 | biàn shì / Followed immediately by; was simply. | fix|word|biàn shì|then it is; and then came (literary 就是) | 』接连便是难懂的话，什么『君子固穷』，什么『者乎』之… |
| 难懂 | nán dǒng / Hard to understand. | ok | 』接连便是难懂的话，什么『君子固穷』，什么『者乎』之… |
| 乎 | hū / Classical Chinese question/exclamation particle, used here in a pedantic quoted phrase. | ok | 』接连便是难懂的话，什么『君子固穷』，什么『者乎』之… |
| 之类 | zhī lèi / And so on; things like that. | ok | 』接连便是难懂的话，什么『君子固穷』，什么『者乎』之… |
| 哄笑 | hōng xiào / To burst out laughing; a roar of laughter. | ok | 』接连便是难懂的话，什么『君子固穷』，什么『者乎』之… |
| 背地里 | bèi dì li / Behind someone's back; secretly. | ok | 听人家背地里谈论，孔乙己原来也读过书，但终于没有进学… |
| 进学 | jìn xué / To pass the entry-level imperial exam and become a licensed scholar (xiucai). | ok | 听人家背地里谈论，孔乙己原来也读过书，但终于没有进学… |
| 不会 | bù huì / Not know how to (do something). | ok | 听人家背地里谈论，孔乙己原来也读过书，但终于没有进学… |
| 营生 | yíng shēng / To earn a living. | ok | 听人家背地里谈论，孔乙己原来也读过书，但终于没有进学… |
| 讨饭 | tǎo fàn / to beg for food | ok | 于是愈过愈穷，弄到将要讨饭了。 |
| 幸而 | xìng ér / Fortunately; luckily. | ok | 幸而写得一笔好字，便替人家钞钞书，换一碗饭吃。 |
| 钞 | chāo / To copy (text) by hand. | ok | 幸而写得一笔好字，便替人家钞钞书，换一碗饭吃。 |
| 好喝 | hào hē / Fond of drinking (alcohol) — note: here 好 is read hào ("to be fond of"), not hǎo. | fix|word|hào hē|Fond of drinking (alcohol); given to drink. | 可惜他又有一样坏脾气，便是好喝懒做。 |
| 不到 | bù dào / Less than; not even reaching (a certain amount of time). | ok | 坐不到几天，便连人和书籍纸张笔砚，一齐失踪。 |
| 纸张 | zhǐ zhāng / paper | ok | 坐不到几天，便连人和书籍纸张笔砚，一齐失踪。 |
| 笔砚 | bǐ yàn / writing brush and inkstone | ok | 坐不到几天，便连人和书籍纸张笔砚，一齐失踪。 |
| 如是 | rú shì / thus; like this | ok | 如是几次，叫他钞书的人也没有了。 |
| 几次 | jǐ cì / several times | ok | 如是几次，叫他钞书的人也没有了。 |
| 间或 | jiàn huò / occasionally; now and then | ok | 虽然间或没有现钱，暂时记在粉板上，但不出一月，定然还… |
| 现钱 | xiàn qián / cash; ready money | ok | 虽然间或没有现钱，暂时记在粉板上，但不出一月，定然还… |
| 粉板 | fěn bǎn / chalkboard used to record customers' running tabs | ok | 虽然间或没有现钱，暂时记在粉板上，但不出一月，定然还… |
| 定然 | dìng rán / certainly; surely | ok | 虽然间或没有现钱，暂时记在粉板上，但不出一月，定然还… |
| 还清 | huán qīng / to pay off in full | ok | 虽然间或没有现钱，暂时记在粉板上，但不出一月，定然还… |
| 涨红 | zhàng hóng / flushed red (in the face) | ok | 孔乙己喝过半碗酒，涨红的脸色渐渐复了原，旁人便又问道… |
| 复 | fù / to return to normal; to recover (its usual state) | ok | 孔乙己喝过半碗酒，涨红的脸色渐渐复了原，旁人便又问道… |
| 问道 | wèn dào / asked (said while asking, in dialogue) | ok | 孔乙己喝过半碗酒，涨红的脸色渐渐复了原，旁人便又问道… |
| 显出 | xiǎn chū / to show; to display (an expression) | ok | 』孔乙己看着问他的人，显出不屑置辩的神气。 |
| 置辩 | zhì biàn / to argue back; to defend oneself | ok | 』孔乙己看着问他的人，显出不屑置辩的神气。 |
| 说道 | shuō dào / said, saying | ok | 他们便接着说道：『你怎的连半个秀才也捞不到呢？ |
| 怎 | zěn / how (as in "how is it that...") | ok | 他们便接着说道：『你怎的连半个秀才也捞不到呢？ |
| 半个 | bàn ge / half a | ok | 他们便接着说道：『你怎的连半个秀才也捞不到呢？ |
| 秀才 | xiù cai / xiucai — scholar who passed the county-level imperial exam | fix|word|xiù cai|scholar who passed the county-level imperial exam | 他们便接着说道：『你怎的连半个秀才也捞不到呢？ |
| 颓唐 | tuí táng / dejected; downcast | ok | 』孔乙己立刻显出颓唐不安模样，脸上笼上了一层灰色，嘴… |
| 笼 | lóng / to envelop/cover (a color or expression spreading over someone's face) | fix|word|lǒng|to cover; to envelop | 』孔乙己立刻显出颓唐不安模样，脸上笼上了一层灰色，嘴… |
| 一层 | yī céng / a layer (of) | ok | 』孔乙己立刻显出颓唐不安模样，脸上笼上了一层灰色，嘴… |
| 嘴里 | zuǐ lǐ / in one's mouth (mumbling something) | ok | 』孔乙己立刻显出颓唐不安模样，脸上笼上了一层灰色，嘴… |
| 决不 | jué bù / never; absolutely not | ok | 在这些时候，我可以附和着笑，掌柜是决不责备的。 |
| 发笑 | fā xiào / to make people laugh; to get a laugh | fix|word|fā xiào|to laugh; to burst out laughing | 而且掌柜见了孔乙己，也每每这样问他，引人发笑。 |
| 谈天 | tán tiān / to chat | ok | 孔乙己自己知道不能和他们谈天，便只好向孩子说话。 |
| 略略 | lüè lüè / slightly; a little | ok | 』我略略点一点头。 |
| 不再 | bù zài / no longer | ok | 便回过脸去，不再理会。 |
| 许久 | xǔ jiǔ / for a long time | ok | 孔乙己等了许久，很恳切的说道：『不能写罢？ |
| 帐 | zhàng / account; bill (bookkeeping records) | ok | 将来做掌柜的时候，写帐要用。 |
| 暗想 | àn xiǎng / to think to oneself | ok | 』我暗想我和掌柜的等级还很远呢，而且我们掌柜也从不将… |
| 不是 | bù shì / isn't it; is not | ok | 又好笑，又不耐烦，懒懒的答他道：『谁要你教，不是草头… |
| 指头 | zhǐ tou / finger | ok | 』孔乙己显出极高兴的样子，将两个指头的长指甲敲着柜台… |
| 写法 | xiě fǎ / way of writing a character | ok | ……回字有四样写法，你知道么？ |
| 写字 | xiě zì / to write characters | ok | 孔乙己刚用指甲蘸了酒，想在柜上写字，见我毫不热心，便… |
| 叹 | tàn / to sigh | ok | 孔乙己刚用指甲蘸了酒，想在柜上写字，见我毫不热心，便… |
| 邻舍 | lín shè / neighbor | ok | 有几回，邻舍孩子听得笑声，也赶热闹，围住了孔乙己。 |
| 笑声 | xiào shēng / laughter; sound of laughing | ok | 有几回，邻舍孩子听得笑声，也赶热闹，围住了孔乙己。 |
| 围住 | wéi zhù / to surround; to crowd around | ok | 有几回，邻舍孩子听得笑声，也赶热闹，围住了孔乙己。 |
| 碟子 | dié zi / small dish; saucer | ok | 孩子吃完豆，仍然不散，眼睛都望着碟子。 |
| 伸开 | shēn kāi / to stretch out (one's hand) | ok | 孔乙己着了慌，伸开五指将碟子罩住，弯腰下去说道：『不… |
| 五指 | wǔ zhǐ / the five fingers | ok | 孔乙己着了慌，伸开五指将碟子罩住，弯腰下去说道：『不… |
| 弯腰 | wān yāo / to bend at the waist; to stoop | ok | 孔乙己着了慌，伸开五指将碟子罩住，弯腰下去说道：『不… |
| 起身 | qǐ shēn / to get up; rise to one's feet | ok | 』直起身又看一看豆，自己摇头说：『不多不多！ |
| 看一看 | kàn yī kàn / to take a look; have a glance | ok | 』直起身又看一看豆，自己摇头说：『不多不多！ |
| 豆 | dòu / bean; pea (the snack he's doling out) | fix|word|dòu|bean; pea | 』直起身又看一看豆，自己摇头说：『不多不多！ |
| 摇头 | yáo tóu / to shake one's head | ok | 』直起身又看一看豆，自己摇头说：『不多不多！ |
| 走散 | zǒu sàn / to disperse; wander off | ok | 』于是这一群孩子都在笑声里走散了。 |
| 中秋 | Zhōng qiū / the Mid-Autumn Festival | fix|name|Zhōng qiū|the Mid-Autumn Festival | 有一天，大约是中秋前的两三天，掌柜正在慢慢的结帐，取… |
| 结帐 | jié zhàng / to settle accounts; tally up the bill | ok | 有一天，大约是中秋前的两三天，掌柜正在慢慢的结帐，取… |
| 发昏 | fā hūn / to be muddleheaded; act rashly, out of one's senses | ok | 这一回，是自己发昏，竟偸到丁举人家里去了。 |
| 举人 | jǔ rén / successful candidate in the imperial provincial exam | ok | 这一回，是自己发昏，竟偸到丁举人家里去了。 |
| 家里 | jiā lǐ / home; house | ok | 这一回，是自己发昏，竟偸到丁举人家里去了。 |
| 服辩 | fú biàn / written confession | ok | 先写服辩，后来是打，打了大半夜，再打折了腿。 |
| 晓得 | xiǎo de / to know | ok | ……谁晓得？ |
| 看看 | kàn kan / soon; before long | ok | 中秋过后，秋风是一天凉比一天，看看将近初冬； |
| 初冬 | chū dōng / early winter | ok | 中秋过后，秋风是一天凉比一天，看看将近初冬； |
| 棉袄 | mián ǎo / cotton-padded jacket | ok | 我整天的靠着火，也须穿上棉袄了。 |
| 耳熟 | ěr shú / familiar-sounding | ok | 』这声音虽然极低，却很耳熟。 |
| 向外 | xiàng wài / outward; toward the outside | ok | 站起来向外一望，那孔乙己便在柜台下对了门槛坐着。 |
| 夹袄 | jiá ǎo / lined (double-layered, unpadded) jacket | ok | 穿一件破夹袄，盘着两腿，下面垫一个蒲包，用草绳在肩上… |
| 蒲包 | pú bāo / cattail-leaf mat used as a cushion | fix|word|pú bāo|bag woven from cattail leaves (used here as a seat cushion) | 穿一件破夹袄，盘着两腿，下面垫一个蒲包，用草绳在肩上… |
| 肩 | jiān / shoulder | ok | 穿一件破夹袄，盘着两腿，下面垫一个蒲包，用草绳在肩上… |
| 挂住 | guà zhù / to fasten by hooking over; hold in place | ok | 穿一件破夹袄，盘着两腿，下面垫一个蒲包，用草绳在肩上… |
| 下回 | xià huí / next time | ok | 』孔乙己很颓唐的仰面答道，『这……下回还清罢。 |
| 分辩 | fēn biàn / to argue in one's own defense; to protest an accusation | ok | 』但他这回却不十分分辩，单说了一句『不要取笑！ |
| 一句 | yī jù / one sentence/remark (a single thing said) | ok | 』但他这回却不十分分辩，单说了一句『不要取笑！ |
| 低声 | dī shēng / in a low voice; softly | ok | 』孔乙己低声说道：『跌断，跌，跌……』他的眼色，很像… |
| 几个 | jǐ ge / several; a few (people) | ok | 此时已经聚集了几个人，便和掌柜都笑了。 |
| 衣袋 | yī dài / pocket (in clothing) | ok | 他从破衣袋里摸出四文大钱，放在我手里，见他满手是泥，… |
| 手里 | shǒu lǐ / in(to) someone's hand | ok | 他从破衣袋里摸出四文大钱，放在我手里，见他满手是泥，… |
| 满手 | mǎn shǒu / hands entirely covered (with something) | ok | 他从破衣袋里摸出四文大钱，放在我手里，见他满手是泥，… |
| 不一会 | bù yī huì / before long; in a little while | ok | 不一会，他喝完酒，便又在旁人的说笑声中，坐着用这手慢… |
| 年关 | nián guān / year-end (traditionally when debts came due) | ok | 到了年关，掌柜取下粉板说：『孔乙己还欠十九个钱呢！ |

### name (3)

| word | verdict | confirm | sentence |
|---|---|---|---|
| 孔乙己 | Kǒng Yǐjǐ / Kong Yiji — the protagonist | ok | 只有孔乙己到店，才可以笑几声，所以至今还记得。 |
| 端午 | Duān wǔ / Dragon Boat Festival — early-summer holiday; here a debt-repayment deadline | fix|name|Duān wǔ|Dragon Boat Festival (5th day of the 5th lunar month) | 』到第二年的端午，又说：『孔乙己还欠十九个钱呢！ |
| 三月 | Sān yuè / March — the month, in the story's closing date stamp | fix|word|sān yuè|March; the third month | （一九一九年三月。 |

### artifact (3)

| word | verdict | confirm | sentence |
|---|---|---|---|
| 有水 | Not a fixed term here — just 有 (have) + 水 (water), literally "had water [in it]," checking whether the pot held water; unrelated to the CEDICT sense "supplied with water (of a house)" | fix|artifact|yǒu shuǐ|segmentation artifact: "have water" (in it), not a fixed word | 他们往往要亲眼看着黄酒从坛子里舀出，看过壶子底里有水… |
| 引得 | Not a fixed dictionary word here — it's 引 ("to provoke/cause") + 得 (resultative complement marker meaning "to the point that/so as to"), together meaning "caused everyone to burst out laughing." | fix|artifact|yǐn dé|not one word here: 引 "to cause" + resultative 得, i.e. "caused (everyone) to..." | 』接连便是难懂的话，什么『君子固穷』，什么『者乎』之… |
| 一月 | Not the word "January" — here 一 (one) + 月 (month) is just a numeral phrase meaning "a month" (不出一月 = "before a month is out"), not the calendar-month lexeme | fix|artifact|yī yuè|Segmentation artifact: "one" + "month" meaning "a month", not the calendar month January. | 虽然间或没有现钱，暂时记在粉板上，但不出一月，定然还… |

## Phase C — not in CEDICT (routing; 7 fixed by confirm)

### name (2)

| token | verdict | confirm | sentence |
|---|---|---|---|
| 鲁镇 | Lǔ Zhèn / fictional town setting of the story (based on Lu Xun's hometown Shaoxing; recurs in other stories like 祝福) | ok | 鲁镇的酒店的格局，是和别处不同的：都是当街一个曲尺形… |
| 咸亨 | Xiánhēng / name of the tavern (咸亨酒店) where the narrator works; a real Shaoxing tavern, later famous because of this story | ok | 我从十二岁起，便在镇口的咸亨酒店里当伙计，掌柜说，样… |

### artifact (47)

| token | verdict | confirm | sentence |
|---|---|---|---|
| 要涨 | 要 / 涨 | ok | 做工的人，傍午傍晚散了工，每每花四文铜钱，买一碗酒—… |
| 倘肯 | 倘 / 肯 | ok | 倘肯多花一文，便可以买一碟盐煮笋，或者茴香豆，做下酒… |
| 出到 | 出 / 到 | ok | 倘肯多花一文，便可以买一碟盐煮笋，或者茴香豆，做下酒… |
| 做点事 | 做 / 点事 | ok | 我从十二岁起，便在镇口的咸亨酒店里当伙计，掌柜说，样… |
| 舀出 | 舀 / 出 | ok | 他们往往要亲眼看着黄酒从坛子里舀出，看过壶子底里有水… |
| 放在 | 放 / 在 | ok | 他们往往要亲眼看着黄酒从坛子里舀出，看过壶子底里有水… |
| 干不了 | 干 / 不了 | ok | 所以过了几天，掌柜又说我干不了这事。 |
| 这事 | 这 / 事 | ok | 所以过了几天，掌柜又说我干不了这事。 |
| 总觉 | 总 / 觉 | ok | 虽然没有什么失职，但总觉有些单调，有些无聊。 |
| 教人 | 教 / 人 | ok | 掌柜是一副凶脸孔，主顾也没有好声气，教人活泼不得； |
| 上的 | 上 / 的 | ok | 因为他姓孔，别人便从描红纸上的『上大人孔乙己』这半懂… |
| 柜里说 | 柜里 / 说 | ok | 』他不回答，对柜里说：『温两碗酒，要一碟茴香豆。 |
| 睁大眼睛 | 睁大 / 眼睛 | ok | 』孔乙己睁大眼睛说：『你怎么这样凭空污人清白……』『… |
| 污人 | 污 / 人 | ok | 』孔乙己睁大眼睛说：『你怎么这样凭空污人清白……』『… |
| 见你 | 见 / 你 | ok | 我前天亲眼见你偸了何家的书，吊着打。 |
| 涨红了脸 | 涨红 / 了|脸 | ok | 』孔乙己便涨红了脸，额上的青筋条条绽出，争辩道：『窃… |
| 能算 | 能 / 算 | ok | ……读书人的事，能算偸么？ |
| 过书 | 过 / 书 | ok | 听人家背地里谈论，孔乙己原来也读过书，但终于没有进学… |
| 愈穷 | 愈 / 穷 | ok | 于是愈过愈穷，弄到将要讨饭了。 |
| 写得 | 写 / 得 | ok | 幸而写得一笔好字，便替人家钞钞书，换一碗饭吃。 |
| 好字 | 好 / 字 | ok | 幸而写得一笔好字，便替人家钞钞书，换一碗饭吃。 |
| 记在 | 记 / 在 | ok | 虽然间或没有现钱，暂时记在粉板上，但不出一月，定然还… |
| 拭去 | 拭 / 去 | fix|word|shì qù|to wipe away, wipe off, erase | 虽然间或没有现钱，暂时记在粉板上，但不出一月，定然还… |
| 说些话 | 说 / 些|话 | ok | 』孔乙己立刻显出颓唐不安模样，脸上笼上了一层灰色，嘴… |
| 全是 | 全 / 是 | ok | 这回可是全是之乎者也之类，一些不懂了。 |
| 引人 | 引 / 人 | ok | 而且掌柜见了孔乙己，也每每这样问他，引人发笑。 |
| 茴字 | 茴 / 字 | ok | 茴香豆的茴字，怎样写的？ |
| 写的 | 写 / 的 | ok | 茴香豆的茴字，怎样写的？ |
| 配考 | 配 / 考 | ok | 』我想，讨饭一样的人，也配考我么？ |
| 脸去 | 脸 / 去 | ok | 便回过脸去，不再理会。 |
| 他道 | 他 / 道 | ok | 又好笑，又不耐烦，懒懒的答他道：『谁要你教，不是草头… |
| 回字么 | 回字 / 么 | fix|artifact|回|字|么 | 又好笑，又不耐烦，懒懒的答他道：『谁要你教，不是草头… |
| 努着嘴 | 努 / 着|嘴 | ok | 』我愈不耐烦了，努着嘴走远。 |
| 刚用 | 刚 / 用 | ok | 孔乙己刚用指甲蘸了酒，想在柜上写字，见我毫不热心，便… |
| 完豆 | 完 / 豆 | ok | 孩子吃完豆，仍然不散，眼睛都望着碟子。 |
| 会来 | 会 / 来 | ok | 一个喝酒的人说道，『他怎么会来？ |
| 他家 | 他 / 家 | ok | 他家的东西，偸得的么？ |
| 先写 | 先 / 写 | ok | 先写服辩，后来是打，打了大半夜，再打折了腿。 |
| 凉比 | 凉 / 比 | ok | 中秋过后，秋风是一天凉比一天，看看将近初冬； |
| 正合 | 正 / 合 | ok | 一天的下半天，没有一个顾客，我正合了眼坐着。 |
| 极低 | 极 / 低 | ok | 』这声音虽然极低，却很耳熟。 |
| 看时 | 看 / 时 | ok | 看时又全没有人。 |
| 伸出头 | 伸出 / 头 | ok | 』掌柜也伸出头去，一面说：『孔乙己么？ |
| 你又 | 你 / 又 | ok | 』掌柜仍然同平常一样，笑着对他说，『孔乙己，你又偸了… |
| 我温 | 我 / 温 | ok | 我温了酒，端出去，放在门槛上。 |
| 这手 | 这 / 手 | ok | 他从破衣袋里摸出四文大钱，放在我手里，见他满手是泥，… |
| 又说 | 又 / 说 | ok | 』到第二年的端午，又说：『孔乙己还欠十九个钱呢！ |

### word (31)

| token | verdict | confirm | sentence |
|---|---|---|---|
| 曲尺形 | qūchǐxíng / L-shaped, bent like a carpenter's square (describes the counter's shape) | ok | 鲁镇的酒店的格局，是和别处不同的：都是当街一个曲尺形… |
| 豫备 | yùbèi / to prepare, get ready (1919 variant spelling of modern 预备) | ok | 鲁镇的酒店的格局，是和别处不同的：都是当街一个曲尺形… |
| 镇口 | zhènkǒu / entrance/edge of town, where the road meets the town | ok | 我从十二岁起，便在镇口的咸亨酒店里当伙计，掌柜说，样… |
| 壶子 | húzi / pot, jug (esp. a wine-warming vessel); era-variant of 壶 | ok | 他们往往要亲眼看着黄酒从坛子里舀出，看过壶子底里有水… |
| 嚷道 | rǎng dào / shouted out, exclaimed loudly (X道 "said X-ly" pattern common in vernacular fiction) | ok | 他们又故意的高声嚷道：『你一定又偸了人家的东西了！ |
| 绽出 | zhàn chū / to burst/split open and protrude (of veins, seams) | ok | 』孔乙己便涨红了脸，额上的青筋条条绽出，争辩道：『窃… |
| 君子固穷 | jūnzǐ gù qióng / a gentleman stays steadfast even in poverty (Analects quotation) | ok | 』接连便是难懂的话，什么『君子固穷』，什么『者乎』之… |
| 不出 | bù chū / within (a period of time); not exceeding | ok | 虽然间或没有现钱，暂时记在粉板上，但不出一月，定然还… |
| 这回 | zhè huí / this time, on this occasion (implies something different happens this time) | ok | 这回可是全是之乎者也之类，一些不懂了。 |
| 这时候 | zhè shíhou / at this time, at this moment | ok | 在这时候，众人也都哄笑起来：店内外充满了快活的空气。 |
| 教给 | jiāo gěi / to teach (something) to (someone), pass on (knowledge) | ok | ……我教给你，记着！ |
| 掌柜的 | zhǎng guì de / shopkeeper, boss of a shop (colloquial, 掌柜 + 的) | fix|artifact|掌柜|的 | 将来做掌柜的时候，写帐要用。 |
| 上帐 | shàng zhàng / to record on the account/tab (era variant of modern 上账) | ok | 』我暗想我和掌柜的等级还很远呢，而且我们掌柜也从不将… |
| 草头 | cǎotóu / the "grass" radical 艹 atop a character | ok | 又好笑，又不耐烦，懒懒的答他道：『谁要你教，不是草头… |
| 走远 | zǒu yuǎn / to walk off into the distance | fix|artifact|走|远 | 』我愈不耐烦了，努着嘴走远。 |
| 听得 | tīngde / heard, caught the sound of | ok | 有几回，邻舍孩子听得笑声，也赶热闹，围住了孔乙己。 |
| 不散 | bú sàn / wouldn't leave, didn't disperse | fix|artifact|不|散 | 孩子吃完豆，仍然不散，眼睛都望着碟子。 |
| 罩住 | zhàozhù / to cover something over and pin it down/trap it in place | ok | 孔乙己着了慌，伸开五指将碟子罩住，弯腰下去说道：『不… |
| 不多 | bù duō / not much, not many | fix|artifact|不|多 | 孔乙己着了慌，伸开五指将碟子罩住，弯腰下去说道：『不… |
| 多乎哉 | duō hū zāi / classical phrase "is it a lot?" (literary allusion, echoes the Analects) | ok | 多乎哉？ |
| 许是 | xǔ shì / perhaps, maybe (adverb: "maybe it's that...") | ok | 许是死了。 |
| 秋风 | qiū fēng / autumn wind | ok | 中秋过后，秋风是一天凉比一天，看看将近初冬； |
| 草绳 | cǎo shéng / straw rope/cord | ok | 穿一件破夹袄，盘着两腿，下面垫一个蒲包，用草绳在肩上… |
| 仰面 | yǎng miàn / face turned upward, looking up | ok | 』孔乙己很颓唐的仰面答道，『这……下回还清罢。 |
| 答道 | dá dào / replied, answered (narration verb introducing dialogue) | ok | 』孔乙己很颓唐的仰面答道，『这……下回还清罢。 |
| 单说 | dān shuō / to simply/only say — 单 as adverb "merely" + 说 | fix|artifact|单|说 | 』但他这回却不十分分辩，单说了一句『不要取笑！ |
| 走来 | zǒu lái / to come walking, approach on foot (verb + directional complement) | ok | 他从破衣袋里摸出四文大钱，放在我手里，见他满手是泥，… |
| 喝完 | hē wán / to finish drinking (verb + resultative complement) | ok | 不一会，他喝完酒，便又在旁人的说笑声中，坐着用这手慢… |
| 说笑声 | shuō xiào shēng / the sound of chatting and laughing | ok | 不一会，他喝完酒，便又在旁人的说笑声中，坐着用这手慢… |
| 自此以后 | zì cǐ yǐ hòu / from then on, thereafter | ok | 自此以后，又长久没有看见孔乙己。 |
| 第二年 | dì èr nián / the second year, the next year | ok | 』到第二年的端午，又说：『孔乙己还欠十九个钱呢！ |

