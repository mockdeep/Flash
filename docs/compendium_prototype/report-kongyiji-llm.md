# kongyiji-llm — compendium pipeline prototype report

Text: Lu Xun's short story 孔乙己 (1919, modern vernacular), simplified, 1545 Han tokens, 586 studyable words.
Lexicon stand-in: HSK 1–7 deck (flash-csvs). Sonnet proposes, Opus confirms.

## Coverage

| bucket | unique words | tokens | token share |
|---|---|---|---|
| in lexicon (HSK) | 382 | 1208 | 78.2% |
| new, CEDICT-grounded | 164 | 292 | 18.9% |
| not in CEDICT | 40 | 45 | 2.9% |
| pre-split artifacts (counts fan to parts) | 0 | 0 | 0.0% |

HSK words by level: L1: 105, L2: 48, L3: 49, L4: 61, L5: 41, L6: 34, L7: 44

## Pre-split (deterministic, verified)

0 artifact tokens split by rule: .

## Phase A — match step (existing cards)

346/382 covered by the existing gloss. Of 36 proposed new senses, Opus confirmed 24, rejected 12.

| word | existing gloss | proposed new sense | confirm | sentence |
|---|---|---|---|---|
| 散 | loose; scattered; to come loose; to scatter; to disperse | to end/finish a work shift; to knock off work | ok | 做工的人，傍午傍晚散了工，每每花四文铜钱，买一碗酒—… |
| 文 | writing; language; culture | measure word for an old copper coin (currency unit, "wen") | ok | 做工的人，傍午傍晚散了工，每每花四文铜钱，买一碗酒—… |
| 要 | to want; to need; to ask for | as much as (used before an amount to indicate a high degree reached) | reject|"costs/comes to" here is the taught "to need/require" applied to a price, not a new sense | 做工的人，傍午傍晚散了工，每每花四文铜钱，买一碗酒—… |
| 出 | to go out; to come out | to spend or pay out (money) | ok | 倘肯多花一文，便可以买一碟盐煮笋，或者茴香豆，做下酒… |
| 那 | that; those | then; in that case (connects a condition to its result) | ok | 倘肯多花一文，便可以买一碟盐煮笋，或者茴香豆，做下酒… |
| 起 | to rise | starting from (marks the point in time/place something begins, as in 从...起) | ok | 我从十二岁起，便在镇口的咸亨酒店里当伙计，掌柜说，样… |
| 亲 | close; to kiss | in person; personally (doing something oneself), not "close" or "kiss" | ok | 他们往往要亲眼看着黄酒从坛子里舀出，看过壶子底里有水… |
| 将 | will; shall | literary marker placing the object before the verb (like 把), not the future-tense "will" | ok | 他们往往要亲眼看着黄酒从坛子里舀出，看过壶子底里有水… |
| 为难 | embarrassed; to make things difficult (for someone) | difficult, tricky to manage (of a task or situation, not interpersonal) | reject|"hard to pull off" is the same be-in-a-difficult-position sense already glossed, just impersonal | 他们往往要亲眼看着黄酒从坛子里舀出，看过壶子底里有水… |
| 不得 | must not | cannot; not able to (as a verb complement: V + 不得 = can't be V-ed) | ok | 幸亏荐头的情面大，辞退不得，便改为专管温酒的一种无聊… |
| 什么 | what? | any (indefinite, used in negative sentences, not a question word) | ok | 虽然没有什么失职，但总觉有些单调，有些无聊。 |
| 教 | to teach | to cause/make (someone do something); causative verb | ok | 掌柜是一副凶脸孔，主顾也没有好声气，教人活泼不得； |
| 间 | classifier for rooms | among; in between (spatial, not a room classifier) | ok | 青白脸色，皱纹间时常夹些伤痕； |
| 夹 | to press from either side | interspersed among; mixed in between | ok | 青白脸色，皱纹间时常夹些伤痕； |
| 部 | ministry; department; classifier for films, books | classifier for a thick mass or growth (e.g., a beard) | ok | 一部乱蓬蓬的花白的胡子。 |
| 孔 | aperture; small hole | surname Kong | ok | 因为他姓孔，别人便从描红纸上的『上大人孔乙己』这半懂… |
| 道 | road; way; classifier for rivers, walls, dishes, or questions | to say (used to introduce direct speech, as in "said") | ok | 』孔乙己便涨红了脸，额上的青筋条条绽出，争辩道：『窃… |
| 者 | one who (is) ... | classical-style function word, cited here as an example token of archaic bookish phrases (as in 之乎者也), not used to nominalize a verb | reject|word is quoted as a specimen of classical diction, not used in a distinct lexical sense | 』接连便是难懂的话，什么『君子固穷』，什么『者乎』之… |
| 起来 | to stand up; to get up | verb complement after a verb, marking the start of an action ("burst out ~ing") | ok | 』接连便是难懂的话，什么『君子固穷』，什么『者乎』之… |
| 笔 | pen | measure word for a stroke/style of handwriting (as in "a fine hand of characters") | ok | 幸而写得一笔好字，便替人家钞钞书，换一碗饭吃。 |
| 叫 | to call; to be called; to shout | to tell/have someone do something | ok | 如是几次，叫他钞书的人也没有了。 |
| 就是 | exactly; just; even if | namely; that is to say (introducing a specific example or elaboration) | reject|"namely/that is" is a discourse nuance of the taught "just; exactly" | 但他在我们店里，品行却比别人都好，就是从不拖欠； |
| 捞 | to fish up | to obtain, get, or land something (often through effort, luck, or underhanded means) — figurative, not literal fishing | ok | 他们便接着说道：『你怎的连半个秀才也捞不到呢？ |
| 头 | head; suffix for nouns | classifier for a countable occurrence/instance (measure word for actions) | reject|头 here is the literal noun "head" (点点头 = nod one's head), already taught | 』我略略点一点头。 |
| 去 | to go | away (used after a verb to show the action moves away from the speaker, e.g. turned away) | ok | 便回过脸去，不再理会。 |
| 再 | again | to bother with; to acknowledge (someone's presence/attempt to engage) | reject|proposed sense belongs to 理会, not 再; 再 here is just "again/anymore" in 不再 | 便回过脸去，不再理会。 |
| 应该 | should | these characters ought to be memorized | reject|not a sense, just the sentence's translation; 应该 = "should" as taught | 这些字应该记着。 |
| 口 | mouth; classifier for family members; classifier for bites | classifier for a breath/sigh, as in 一口气 "a sigh/breath" | reject|一口气 is the mouthful/bite classifier already taught, applied to breath | 孔乙己刚用指甲蘸了酒，想在柜上写字，见我毫不热心，便… |
| 热闹 | lively; bustling (of a place or scene) | to join in for the fun/excitement (noun use in 赶热闹, "join the crowd to see what's going on") | reject|noun use in 赶热闹 is a grammatical variation of the taught "lively; bustling" | 有几回，邻舍孩子听得笑声，也赶热闹，围住了孔乙己。 |
| 指 | to point at; to refer to | finger (noun, as in 五指 "five fingers") | ok | 孔乙己着了慌，伸开五指将碟子罩住，弯腰下去说道：『不… |
| 打折 | to give a discount | to break something (e.g. a bone) by hitting or beating it | ok | 先写服辩，后来是打，打了大半夜，再打折了腿。 |
| 时 | time; hour | when (used after a verb: "at the time of doing X") | reject|V+时 "when" is the taught noun "time" in a temporal clause, not a separate sense | 看时又全没有人。 |
| 盘 | classifier for dishes; classifier for board games | to sit cross-legged; to coil (legs) under oneself | ok | 穿一件破夹袄，盘着两腿，下面垫一个蒲包，用草绳在肩上… |
| 单 | single; sole; odd (number); bill | merely; only (adverb, not "single/sole" as adjective) | reject|adverbial "only/merely" is a grammatical extension of the taught "single/sole", not a new sense | 』但他这回却不十分分辩，单说了一句『不要取笑！ |
| 打断 | to interrupt | to break (a bone/limb) | ok | 要是不偸，怎么会打断腿？ |
| 摸 | to touch; to stroke | to feel around for; to grope for (and pull something out, e.g. from a pocket) | reject|"feel around and draw out" is the taught tactile sense plus resultative 出 | 他从破衣袋里摸出四文大钱，放在我手里，见他满手是泥，… |

## Phase B — new words glossed against CEDICT (20 fixed by confirm)

### word (162)

| word | verdict | confirm | sentence |
|---|---|---|---|
| 别处 | bié chù / elsewhere; a different place | ok | 鲁镇的酒店的格局，是和别处不同的：都是当街一个曲尺形… |
| 当街 | dāng jiē / facing the street; right on the street | ok | 鲁镇的酒店的格局，是和别处不同的：都是当街一个曲尺形… |
| 柜 | guì / counter; cabinet (here: the counter/cupboard behind the bar) | fix|word|guì|counter; cabinet | 鲁镇的酒店的格局，是和别处不同的：都是当街一个曲尺形… |
| 热水 | rè shuǐ / hot water | ok | 鲁镇的酒店的格局，是和别处不同的：都是当街一个曲尺形… |
| 温 | wēn / to warm up (wine/food) | ok | 鲁镇的酒店的格局，是和别处不同的：都是当街一个曲尺形… |
| 做工 | zuò gōng / to do manual labor; work with one's hands | ok | 做工的人，傍午傍晚散了工，每每花四文铜钱，买一碗酒—… |
| 傍午 | bàng wǔ / around noon; toward midday | ok | 做工的人，傍午傍晚散了工，每每花四文铜钱，买一碗酒—… |
| 工 | gōng / work; a work shift | ok | 做工的人，傍午傍晚散了工，每每花四文铜钱，买一碗酒—… |
| 每每 | měi měi / often; frequently | ok | 做工的人，傍午傍晚散了工，每每花四文铜钱，买一碗酒—… |
| 铜钱 | tóng qián / copper coin | ok | 做工的人，傍午傍晚散了工，每每花四文铜钱，买一碗酒—… |
| 二十 | èr shí / twenty | ok | 做工的人，傍午傍晚散了工，每每花四文铜钱，买一碗酒—… |
| 倘 | tǎng / if; supposing | ok | 倘肯多花一文，便可以买一碟盐煮笋，或者茴香豆，做下酒… |
| 笋 | sǔn / bamboo shoot | ok | 倘肯多花一文，便可以买一碟盐煮笋，或者茴香豆，做下酒… |
| 茴香豆 | huí xiāng dòu / fennel-flavored dried beans (a snack) | fix|word|huí xiāng dòu|anise-flavored fava beans (a Shaoxing snack) | 倘肯多花一文，便可以买一碟盐煮笋，或者茴香豆，做下酒… |
| 下酒 | xià jiǔ / to go well with alcohol; an accompaniment to drinking | ok | 倘肯多花一文，便可以买一碟盐煮笋，或者茴香豆，做下酒… |
| 物 | wù / thing; item | ok | 倘肯多花一文，便可以买一碟盐煮笋，或者茴香豆，做下酒… |
| 十几 | shí jǐ / a dozen or more; more than ten | ok | 倘肯多花一文，便可以买一碟盐煮笋，或者茴香豆，做下酒… |
| 荤菜 | hūn cài / a meat dish | ok | 倘肯多花一文，便可以买一碟盐煮笋，或者茴香豆，做下酒… |
| 短衣帮 | duǎn yī bāng / the working class; laborers (lit. "short-jacket crowd") | ok | 倘肯多花一文，便可以买一碟盐煮笋，或者茴香豆，做下酒… |
| 大抵 | dà dǐ / generally; for the most part | ok | 倘肯多花一文，便可以买一碟盐煮笋，或者茴香豆，做下酒… |
| 长衫 | cháng shān / a long gown — traditional formal robe worn by men of higher status | ok | 只有穿长衫的，才踱进店面隔壁的房子里，要酒要菜，慢慢… |
| 踱 | duó / to stroll or pace slowly | ok | 只有穿长衫的，才踱进店面隔壁的房子里，要酒要菜，慢慢… |
| 店面 | diàn miàn / shop front; the front room of a shop | ok | 只有穿长衫的，才踱进店面隔壁的房子里，要酒要菜，慢慢… |
| 十二 | shí èr / twelve | ok | 我从十二岁起，便在镇口的咸亨酒店里当伙计，掌柜说，样… |
| 伙计 | huǒ ji / shop assistant; clerk | ok | 我从十二岁起，便在镇口的咸亨酒店里当伙计，掌柜说，样… |
| 掌柜 | zhǎng guì / shopkeeper; the boss of a shop | ok | 我从十二岁起，便在镇口的咸亨酒店里当伙计，掌柜说，样… |
| 儍 | shǎ / foolish; stupid-looking | ok | 我从十二岁起，便在镇口的咸亨酒店里当伙计，掌柜说，样… |
| 不了 | bù liǎo / unable to (do something) — as in "couldn't manage to" | ok | 我从十二岁起，便在镇口的咸亨酒店里当伙计，掌柜说，样… |
| 主顾 | zhǔ gù / customer; patron | ok | 我从十二岁起，便在镇口的咸亨酒店里当伙计，掌柜说，样… |
| 罢 | ba / sentence-final particle softening a suggestion, like "so..." or "then" | fix|word|ba|sentence-final particle marking a suggestion (variant of 吧) | 我从十二岁起，便在镇口的咸亨酒店里当伙计，掌柜说，样… |
| 短衣 | duǎn yī / a short jacket — plain working-class clothing, contrasted with the long gown | ok | 外面的短衣主顾，虽然容易说话，但唠唠叨叨缠夹不清的也… |
| 唠唠叨叨 | láo lao dāo dāo / to chatter on tediously; to nag | ok | 外面的短衣主顾，虽然容易说话，但唠唠叨叨缠夹不清的也… |
| 缠夹不清 | chán jiā bù qīng / hopelessly confused and hard to deal with (idiom) | ok | 外面的短衣主顾，虽然容易说话，但唠唠叨叨缠夹不清的也… |
| 不少 | bù shǎo / quite a few; not a small number | ok | 外面的短衣主顾，虽然容易说话，但唠唠叨叨缠夹不清的也… |
| 黄酒 | huáng jiǔ / yellow wine — a warmed rice wine | ok | 他们往往要亲眼看着黄酒从坛子里舀出，看过壶子底里有水… |
| 坛子 | tán zi / an earthenware jug or urn | ok | 他们往往要亲眼看着黄酒从坛子里舀出，看过壶子底里有水… |
| 舀 | yǎo / to ladle out; to scoop | ok | 他们往往要亲眼看着黄酒从坛子里舀出，看过壶子底里有水… |
| 之下 | zhī xià / under; given (a certain circumstance) | ok | 他们往往要亲眼看着黄酒从坛子里舀出，看过壶子底里有水… |
| 羼水 | chàn shuǐ / to water down (wine), i.e. to adulterate it | ok | 他们往往要亲眼看着黄酒从坛子里舀出，看过壶子底里有水… |
| 荐头 | jiàn tou / a job broker who arranges employment | ok | 幸亏荐头的情面大，辞退不得，便改为专管温酒的一种无聊… |
| 情面 | qíng miàn / consideration for someone's feelings; "face" or social standing that makes it hard to refuse them | fix|word|qíng miàn|social influence; the "face" that makes someone's request hard to refuse | 幸亏荐头的情面大，辞退不得，便改为专管温酒的一种无聊… |
| 改为 | gǎi wéi / to change (a position/role) into | ok | 幸亏荐头的情面大，辞退不得，便改为专管温酒的一种无聊… |
| 专管 | zhuān guǎn / to be put in sole charge of something | ok | 幸亏荐头的情面大，辞退不得，便改为专管温酒的一种无聊… |
| 整天 | zhěng tiān / all day long | ok | 我从此便整天的站在柜台里，专管我的职务。 |
| 失职 | shī zhí / to neglect one's duties; dereliction of duty | ok | 虽然没有什么失职，但总觉有些单调，有些无聊。 |
| 觉 | jué / to feel; to sense (that something is the case) | ok | 虽然没有什么失职，但总觉有些单调，有些无聊。 |
| 脸孔 | liǎn kǒng / face | ok | 掌柜是一副凶脸孔，主顾也没有好声气，教人活泼不得； |
| 声气 | shēng qì / tone of voice; manner of speaking | ok | 掌柜是一副凶脸孔，主顾也没有好声气，教人活泼不得； |
| 喝酒 | hē jiǔ / to drink wine/alcohol | ok | 孔乙己是站着喝酒而穿长衫的唯一的人。 |
| 青白 | qīng bái / pale, pallid (of a face) | ok | 青白脸色，皱纹间时常夹些伤痕； |
| 乱蓬蓬 | luàn péngpéng / disheveled; unkempt and tangled | fix|word|luàn pēng pēng|disheveled; unkempt and tangled | 一部乱蓬蓬的花白的胡子。 |
| 花白 | huā bái / grizzled; graying | ok | 一部乱蓬蓬的花白的胡子。 |
| 满口 | mǎn kǒu / mouth full of, i.e. speaking constantly in (a certain manner) | fix|word|mǎn kǒu|(of speech) full of; peppered with | 他对人说话，总是满口之乎者也，教人半懂不懂的。 |
| 之乎者也 | zhī hū zhě yě / archaic classical-Chinese particles used to mock pedantic, old-fashioned speech | ok | 他对人说话，总是满口之乎者也，教人半懂不懂的。 |
| 半懂不懂 | bàn dǒng bù dǒng / only half understanding; barely comprehensible | ok | 他对人说话，总是满口之乎者也，教人半懂不懂的。 |
| 话 | huà / words; speech; what someone said | ok | 因为他姓孔，别人便从描红纸上的『上大人孔乙己』这半懂… |
| 叫道 | jiào dào / to call out; to shout | ok | 孔乙己一到店，所有喝酒的人便都看着他笑，有的叫道：『… |
| 伤疤 | shāng bā / scar | ok | 孔乙己一到店，所有喝酒的人便都看着他笑，有的叫道：『… |
| 排出 | pái chū / to lay out/set down (coins) one by one, with a flourish | ok | 』便排出九文大钱。 |
| 大钱 | dà qián / a copper coin of large denomination (old currency) | ok | 』便排出九文大钱。 |
| 高声 | gāo shēng / loudly; in a raised voice | ok | 他们又故意的高声嚷道：『你一定又偸了人家的东西了！ |
| 偸 | tōu / to steal | ok | 他们又故意的高声嚷道：『你一定又偸了人家的东西了！ |
| 凭空 | píng kōng / baseless; without any foundation (of an accusation) | ok | 』孔乙己睁大眼睛说：『你怎么这样凭空污人清白……』『… |
| 污 | wū / to smear; to defile (someone's reputation) | ok | 』孔乙己睁大眼睛说：『你怎么这样凭空污人清白……』『… |
| 清白 | qīng bái / innocence; a clean reputation | ok | 』孔乙己睁大眼睛说：『你怎么这样凭空污人清白……』『… |
| 涨红 | zhàng hóng / to flush red, turn red in the face (from anger/shame) | ok | 』孔乙己便涨红了脸，额上的青筋条条绽出，争辩道：『窃… |
| 额 | é / forehead | ok | 』孔乙己便涨红了脸，额上的青筋条条绽出，争辩道：『窃… |
| 青筋 | qīng jīn / veins (visible under the skin) | ok | 』孔乙己便涨红了脸，额上的青筋条条绽出，争辩道：『窃… |
| 绽 | zhàn / to bulge out, burst forth (of veins under strain) | ok | 』孔乙己便涨红了脸，额上的青筋条条绽出，争辩道：『窃… |
| 窃 | qiè / to steal (formal/literary term) | ok | 』孔乙己便涨红了脸，额上的青筋条条绽出，争辩道：『窃… |
| 不能 | bù néng / cannot; must not | ok | 』孔乙己便涨红了脸，额上的青筋条条绽出，争辩道：『窃… |
| 读书人 | dú shū rén / an educated man; a scholar | ok | ……读书人的事，能算偸么？ |
| 么 | ma / question particle (equivalent to 吗) | fix|word|ma|question particle, equivalent to modern "ma" | ……读书人的事，能算偸么？ |
| 难懂 | nán dǒng / hard to understand | ok | 』接连便是难懂的话，什么『君子固穷』，什么『者乎』之… |
| 固穷 | gù qióng / to bear poverty with honor and without complaint (classical allusion, from the Analects) | ok | 』接连便是难懂的话，什么『君子固穷』，什么『者乎』之… |
| 乎 | hū / classical sentence-final particle marking a question (like 吗/呢), used here to mock pedantic classical speech | fix|word|hū|classical sentence-final question particle, used here to mock pedantic bookish speech | 』接连便是难懂的话，什么『君子固穷』，什么『者乎』之… |
| 之类 | zhī lèi / and so on; things like that | ok | 』接连便是难懂的话，什么『君子固穷』，什么『者乎』之… |
| 哄笑 | hōng xiào / to burst out laughing; a roar of laughter | ok | 』接连便是难懂的话，什么『君子固穷』，什么『者乎』之… |
| 背地里 | bèi dì li / behind someone's back; secretly | ok | 听人家背地里谈论，孔乙己原来也读过书，但终于没有进学… |
| 进学 | jìn xué / to pass the imperial exams and become a licentiate scholar | ok | 听人家背地里谈论，孔乙己原来也读过书，但终于没有进学… |
| 不会 | bù huì / not able to; didn't know how to (do something) | ok | 听人家背地里谈论，孔乙己原来也读过书，但终于没有进学… |
| 营生 | yíng shēng / to earn a living | ok | 听人家背地里谈论，孔乙己原来也读过书，但终于没有进学… |
| 讨饭 | tǎo fàn / to beg for food | ok | 于是愈过愈穷，弄到将要讨饭了。 |
| 幸而 | xìng ér / luckily; fortunately | ok | 幸而写得一笔好字，便替人家钞钞书，换一碗饭吃。 |
| 便是 | biàn shì / namely; that is to say | ok | 可惜他又有一样坏脾气，便是好喝懒做。 |
| 不到 | bù dào / less than; not even (a given amount of time) | ok | 坐不到几天，便连人和书籍纸张笔砚，一齐失踪。 |
| 纸张 | zhǐ zhāng / paper | ok | 坐不到几天，便连人和书籍纸张笔砚，一齐失踪。 |
| 笔砚 | bǐ yàn / writing brush and inkstone | ok | 坐不到几天，便连人和书籍纸张笔砚，一齐失踪。 |
| 如是 | rú shì / thus; like this | ok | 如是几次，叫他钞书的人也没有了。 |
| 钞 | chāo / to copy out (text) — variant of 抄 | fix|word|chāo|to copy out (text) | 如是几次，叫他钞书的人也没有了。 |
| 间或 | jiàn huò / occasionally; now and then | ok | 虽然间或没有现钱，暂时记在粉板上，但不出一月，定然还… |
| 现钱 | xiàn qián / cash; ready money | ok | 虽然间或没有现钱，暂时记在粉板上，但不出一月，定然还… |
| 粉板 | fěn bǎn / chalkboard used to tally unpaid debts | fix|word|fěn bǎn|whitewashed board for temporary notes, e.g. tallying debts | 虽然间或没有现钱，暂时记在粉板上，但不出一月，定然还… |
| 定然 | dìng rán / certainly; surely | ok | 虽然间或没有现钱，暂时记在粉板上，但不出一月，定然还… |
| 还清 | huán qīng / to pay off in full | ok | 虽然间或没有现钱，暂时记在粉板上，但不出一月，定然还… |
| 复 | fù / to return to normal (of a face/complexion) | fix|word|fù|to return to (an original state) | 孔乙己喝过半碗酒，涨红的脸色渐渐复了原，旁人便又问道… |
| 问道 | wèn dào / asked (introduces a quoted question) | ok | 孔乙己喝过半碗酒，涨红的脸色渐渐复了原，旁人便又问道… |
| 显出 | xiǎn chū / to show; to display (an expression) | ok | 』孔乙己看着问他的人，显出不屑置辩的神气。 |
| 说道 | shuō dào / said (introduces quoted speech) | ok | 他们便接着说道：『你怎的连半个秀才也捞不到呢？ |
| 怎的 | zěn de / why; how come | ok | 他们便接着说道：『你怎的连半个秀才也捞不到呢？ |
| 秀才 | xiù cai / scholar who passed the county-level imperial exam (Qing dynasty) | ok | 他们便接着说道：『你怎的连半个秀才也捞不到呢？ |
| 颓唐 | tuí táng / dispirited; dejected | ok | 』孔乙己立刻显出颓唐不安模样，脸上笼上了一层灰色，嘴… |
| 笼 | lǒng / to envelop; to spread over (here: a look spreading over his face) | fix|word|lǒng|to cover; to spread over | 』孔乙己立刻显出颓唐不安模样，脸上笼上了一层灰色，嘴… |
| 决不 | jué bù / not at all; never | ok | 在这些时候，我可以附和着笑，掌柜是决不责备的。 |
| 发笑 | fā xiào / to burst out laughing | ok | 而且掌柜见了孔乙己，也每每这样问他，引人发笑。 |
| 谈天 | tán tiān / to chat | ok | 孔乙己自己知道不能和他们谈天，便只好向孩子说话。 |
| 略略 | lüè lüè / slightly; a little | ok | 』我略略点一点头。 |
| 茴 | huí / fennel (the character being discussed, as in "fennel beans") | fix|word|huí|fennel | 茴香豆的茴字，怎样写的？ |
| 许久 | xǔ jiǔ / for a long time | ok | 孔乙己等了许久，很恳切的说道：『不能写罢？ |
| 帐 | zhàng / account; ledger | ok | 将来做掌柜的时候，写帐要用。 |
| 暗想 | àn xiǎng / to think to oneself | ok | 』我暗想我和掌柜的等级还很远呢，而且我们掌柜也从不将… |
| 不是 | bù shì / isn't it; is not (rhetorical "isn't it...?") | ok | 又好笑，又不耐烦，懒懒的答他道：『谁要你教，不是草头… |
| 指头 | zhǐ tou / finger | ok | 』孔乙己显出极高兴的样子，将两个指头的长指甲敲着柜台… |
| 写法 | xiě fǎ / way of writing a character | ok | ……回字有四样写法，你知道么？ |
| 努 | nǔ / to purse/jut out (the lips, as a gesture) | fix|word|nǔ|to pout; to push out (the lips) | 』我愈不耐烦了，努着嘴走远。 |
| 写字 | xiě zì / to write (by hand) | ok | 孔乙己刚用指甲蘸了酒，想在柜上写字，见我毫不热心，便… |
| 叹 | tàn / to sigh | ok | 孔乙己刚用指甲蘸了酒，想在柜上写字，见我毫不热心，便… |
| 邻舍 | lín shè / neighbor | ok | 有几回，邻舍孩子听得笑声，也赶热闹，围住了孔乙己。 |
| 笑声 | xiào shēng / laughter | ok | 有几回，邻舍孩子听得笑声，也赶热闹，围住了孔乙己。 |
| 围住 | wéi zhù / to surround (a crowd closing in around someone) | ok | 有几回，邻舍孩子听得笑声，也赶热闹，围住了孔乙己。 |
| 吃完 | chī wán / to finish eating | ok | 孩子吃完豆，仍然不散，眼睛都望着碟子。 |
| 豆 | dòu / bean; pea (a legume) | ok | 孩子吃完豆，仍然不散，眼睛都望着碟子。 |
| 碟子 | dié zi / small dish; saucer | ok | 孩子吃完豆，仍然不散，眼睛都望着碟子。 |
| 伸开 | shēn kāi / to stretch out (one's fingers/arms) | ok | 孔乙己着了慌，伸开五指将碟子罩住，弯腰下去说道：『不… |
| 弯腰 | wān yāo / to bend at the waist; to stoop | ok | 孔乙己着了慌，伸开五指将碟子罩住，弯腰下去说道：『不… |
| 摇头 | yáo tóu / to shake one's head | ok | 』直起身又看一看豆，自己摇头说：『不多不多！ |
| 哉 | zāi / classical exclamatory particle: "...indeed!" (here, rhetorical "how much [is there], really?") | fix|word|zāi|classical final particle marking a rhetorical question or exclamation | 多乎哉？ |
| 走散 | zǒu sàn / to scatter; to wander off in different directions | ok | 』于是这一群孩子都在笑声里走散了。 |
| 中秋 | Zhōng qiū / Mid-Autumn Festival (mid-8th-lunar-month moon festival) | fix|name|Zhōng qiū|Mid-Autumn Festival (15th of the 8th lunar month) | 有一天，大约是中秋前的两三天，掌柜正在慢慢的结帐，取… |
| 慢慢 | màn màn / slowly | ok | 有一天，大约是中秋前的两三天，掌柜正在慢慢的结帐，取… |
| 结帐 | jié zhàng / to settle a bill; to tally accounts | ok | 有一天，大约是中秋前的两三天，掌柜正在慢慢的结帐，取… |
| 十九 | shí jiǔ / nineteen | ok | 还欠十九个钱呢！ |
| 发昏 | fā hūn / to be muddle-headed; to lose one's senses and act rashly | ok | 这一回，是自己发昏，竟偸到丁举人家里去了。 |
| 家里 | jiā lǐ / home; household | ok | 这一回，是自己发昏，竟偸到丁举人家里去了。 |
| 服辩 | fú biàn / written confession | ok | 先写服辩，后来是打，打了大半夜，再打折了腿。 |
| 大半夜 | dà bàn yè / the dead of night; middle of the night | fix|word|dà bàn yè|most of the night; the better part of the night | 先写服辩，后来是打，打了大半夜，再打折了腿。 |
| 晓得 | xiǎo de / to know | ok | ……谁晓得？ |
| 不再 | bù zài / no longer | ok | 』掌柜也不再问，仍然慢慢的算他的帐。 |
| 看看 | kàn kan / soon; gradually approaching (coll., of time passing) | ok | 中秋过后，秋风是一天凉比一天，看看将近初冬； |
| 初冬 | chū dōng / early winter | ok | 中秋过后，秋风是一天凉比一天，看看将近初冬； |
| 穿上 | chuān shang / to put on (clothing) | ok | 我整天的靠着火，也须穿上棉袄了。 |
| 棉袄 | mián ǎo / cotton-padded jacket | ok | 我整天的靠着火，也须穿上棉袄了。 |
| 下半天 | xià bàn tiān / afternoon | ok | 一天的下半天，没有一个顾客，我正合了眼坐着。 |
| 耳熟 | ěr shú / to sound familiar | ok | 』这声音虽然极低，却很耳熟。 |
| 站起来 | zhàn qǐ lai / to stand up | ok | 站起来向外一望，那孔乙己便在柜台下对了门槛坐着。 |
| 不成样子 | bù chéng yàng zi / (of a person) looking wretched, a shadow of one's former self | ok | 他脸上黑而且瘦，已经不成样子； |
| 夹袄 | jiá ǎo / lined jacket | ok | 穿一件破夹袄，盘着两腿，下面垫一个蒲包，用草绳在肩上… |
| 蒲包 | pú bāo / cattail-leaf mat/bag, used here as a cushion to sit on | fix|word|pú bāo|cattail-leaf bag (used here as a mat) | 穿一件破夹袄，盘着两腿，下面垫一个蒲包，用草绳在肩上… |
| 挂住 | guà zhù / to fasten/hold in place (by tying) | fix|word|guà zhù|to hang in place; to secure by hanging | 穿一件破夹袄，盘着两腿，下面垫一个蒲包，用草绳在肩上… |
| 伸出 | shēn chū / to stick out, extend (e.g. one's head) | ok | 』掌柜也伸出头去，一面说：『孔乙己么？ |
| 下回 | xià huí / next time | ok | 』孔乙己很颓唐的仰面答道，『这……下回还清罢。 |
| 分辩 | fēn biàn / to argue back, defend oneself against an accusation | ok | 』但他这回却不十分分辩，单说了一句『不要取笑！ |
| 低声 | dī shēng / in a low voice | ok | 』孔乙己低声说道：『跌断，跌，跌……』他的眼色，很像… |
| 跌断 | diē duàn / to break (a bone) in a fall | ok | 』孔乙己低声说道：『跌断，跌，跌……』他的眼色，很像… |
| 衣袋 | yī dài / pocket | ok | 他从破衣袋里摸出四文大钱，放在我手里，见他满手是泥，… |
| 手里 | shǒu lǐ / in (someone's) hand | ok | 他从破衣袋里摸出四文大钱，放在我手里，见他满手是泥，… |
| 一会 | yī huì / a little while | ok | 不一会，他喝完酒，便又在旁人的说笑声中，坐着用这手慢… |
| 说笑 | shuō xiào / to chat and laugh | ok | 不一会，他喝完酒，便又在旁人的说笑声中，坐着用这手慢… |
| 自此 | zì cǐ / from then on | ok | 自此以后，又长久没有看见孔乙己。 |
| 年关 | nián guān / the end of the year (traditional time for settling debts) | ok | 到了年关，掌柜取下粉板说：『孔乙己还欠十九个钱呢！ |
| 第二 | dì èr / second, the next (one) — here: the following year | fix|word|dì èr|second; the next (one) | 』到第二年的端午，又说：『孔乙己还欠十九个钱呢！ |
| 三月 | Sānyuè / March | ok | （一九一九年三月。 |

### name (2)

| word | verdict | confirm | sentence |
|---|---|---|---|
| 孔乙己 | Kǒng Yǐjǐ / Kong Yiji — the protagonist, a poor, unsuccessful scholar clinging to his Confucian pretensions | ok | 只有孔乙己到店，才可以笑几声，所以至今还记得。 |
| 端午 | Duānwǔ / the Dragon Boat Festival, a traditional Chinese holiday | ok | 』到第二年的端午，又说：『孔乙己还欠十九个钱呢！ |

## Phase C — not in CEDICT (routing; 5 fixed by confirm)

### name (5)

| token | verdict | confirm | sentence |
|---|---|---|---|
| 鲁镇 | Lǔ Zhèn / fictional town in Shaoxing, the setting of this story (and other Lu Xun works) | ok | 鲁镇的酒店的格局，是和别处不同的：都是当街一个曲尺形… |
| 咸亨酒店 | Xián hēng Jiǔdiàn / Xianheng Tavern, the (real-life-derived) wineshop where the narrator works | fix|name|Xiánhēng Jiǔdiàn|Xianheng Tavern, the wineshop where the narrator works (based on a real tavern in Shaoxing) | 我从十二岁起，便在镇口的咸亨酒店里当伙计，掌柜说，样… |
| 上大人孔乙己 | Shàng Dà Rén Kǒng Yǐjǐ / opening line of a stock children's calligraphy-primer text; its half-nonsensical phrasing is the source of Kong Yiji's nickname | ok | 因为他姓孔，别人便从描红纸上的『上大人孔乙己』这半懂… |
| 何家 | Hé jiā / the He family (a household mentioned as a theft victim) | ok | 我前天亲眼见你偸了何家的书，吊着打。 |
| 丁举人 | Dīng Jǔrén / Mr. Ding, a "juren" (imperial exam graduate) — the wealthy man Kong Yiji stole from | ok | 这一回，是自己发昏，竟偸到丁举人家里去了。 |

### artifact (2)

| token | verdict | confirm | sentence |
|---|---|---|---|
| 草头 | 草 / 头 | fix|word|cǎotóu|the "grass" radical 艹, written as the top component of a character | 又好笑，又不耐烦，懒懒的答他道：『谁要你教，不是草头… |
| 一九一九 | 一九一九 / (not a segmentation error — this is the numeral "1919" written character-by-character; if forced to split for a lexicon, treat as a single date token, not a compound word) | fix|word|yījiǔyījiǔ|1919 (the year, written out character by character) | （一九一九年三月。 |

### word (33)

| token | verdict | confirm | sentence |
|---|---|---|---|
| 曲尺形 | qū chǐ xíng / L-shaped, like a carpenter's square (曲尺 + 形 "-shaped") | ok | 鲁镇的酒店的格局，是和别处不同的：都是当街一个曲尺形… |
| 豫备 | yù bèi / to prepare, get ready (era variant of modern 预备) | ok | 鲁镇的酒店的格局，是和别处不同的：都是当街一个曲尺形… |
| 热热 | rè re / (of a drink) nice and hot; AA-reduplication of 热 used adverbially | ok | 做工的人，傍午傍晚散了工，每每花四文铜钱，买一碗酒—… |
| 慢慢地 | màn màn de / slowly, unhurriedly (慢慢 + adverbial 地) | ok | 只有穿长衫的，才踱进店面隔壁的房子里，要酒要菜，慢慢… |
| 镇口 | zhèn kǒu / the entrance/edge of town | ok | 我从十二岁起，便在镇口的咸亨酒店里当伙计，掌柜说，样… |
| 壶子 | hú zi / a wine pot/kettle | ok | 他们往往要亲眼看着黄酒从坛子里舀出，看过壶子底里有水… |
| 描红纸 | miáo hóng zhǐ / red-outline copybook paper, used by children to trace characters when learning to write | ok | 因为他姓孔，别人便从描红纸上的『上大人孔乙己』这半懂… |
| 取下 | qǔ xià / to give (someone a nickname); to take off/remove | ok | 因为他姓孔，别人便从描红纸上的『上大人孔乙己』这半懂… |
| 脸上 | liǎn shang / on one's face | ok | 孔乙己一到店，所有喝酒的人便都看着他笑，有的叫道：『… |
| 添上 | tiān shàng / to add on (additionally) | ok | 孔乙己一到店，所有喝酒的人便都看着他笑，有的叫道：『… |
| 嚷道 | rǎng dào / shouted out, said loudly (literary 道 as "said") | ok | 他们又故意的高声嚷道：『你一定又偸了人家的东西了！ |
| 睁大 | zhēng dà / to open (the eyes) wide | ok | 』孔乙己睁大眼睛说：『你怎么这样凭空污人清白……』『… |
| 条条 | tiáo tiáo / each and every one, one by one (AA-reduplication of measure word 条, of veins standing out) | ok | 』孔乙己便涨红了脸，额上的青筋条条绽出，争辩道：『窃… |
| 钞钞 | chāo chāo / to do some copying/transcribing (casual reduplication; modern form 抄抄, 钞 variant of 抄) | ok | 幸而写得一笔好字，便替人家钞钞书，换一碗饭吃。 |
| 好喝懒做 | hào hē lǎn zuò / fond of drink and averse to work (variant of the set phrase 好吃懒做, "lazy glutton") | ok | 可惜他又有一样坏脾气，便是好喝懒做。 |
| 偸窃 | tōu qiè / to steal, theft (变体 of modern 偷窃, 偸 is an old variant of 偷) | fix|word|tōu qiè|to steal; theft (era variant of modern 偷窃; 偸 is an old form of 偷) | 孔乙己没有法，便免不了偶然做些偸窃的事。 |
| 拭去 | shìqù / to wipe away/erase (here: erase from the chalkboard) | ok | 虽然间或没有现钱，暂时记在粉板上，但不出一月，定然还… |
| 不屑置辩 | búxièzhìbiàn / disdaining to argue/debate; too aloof to bother explaining | ok | 』孔乙己看着问他的人，显出不屑置辩的神气。 |
| 这回 | zhèhuí / this time (colloquial for 这次) | ok | 这回可是全是之乎者也之类，一些不懂了。 |
| 教给 | jiāogěi / to teach (someone something); to impart | ok | ……我教给你，记着！ |
| 上帐 | shàngzhàng / to record on the account book/ledger | ok | 』我暗想我和掌柜的等级还很远呢，而且我们掌柜也从不将… |
| 懒懒 | lǎnlǎn / (reduplicated) lazily, listlessly | ok | 又好笑，又不耐烦，懒懒的答他道：『谁要你教，不是草头… |
| 对呀 | duìya / that's right! (colloquial affirmation) | ok | 』孔乙己显出极高兴的样子，将两个指头的长指甲敲着柜台… |
| 罩住 | zhàozhù / to cover/shield completely (with hand or object) | ok | 孔乙己着了慌，伸开五指将碟子罩住，弯腰下去说道：『不… |
| 直起 | zhíqǐ / to straighten up (one's body) | ok | 』直起身又看一看豆，自己摇头说：『不多不多！ |
| 两三天 | liǎngsāntiān / two or three days | ok | 有一天，大约是中秋前的两三天，掌柜正在慢慢的结帐，取… |
| 许是 | xǔshì / perhaps it is the case that; probably | ok | 许是死了。 |
| 秋风 | qiūfēng / autumn wind | ok | 中秋过后，秋风是一天凉比一天，看看将近初冬； |
| 忽然间 | hūránjiān / suddenly, all at once | ok | 忽然间听得一个声音，『温一碗酒。 |
| 草绳 | cǎoshéng / straw rope | ok | 穿一件破夹袄，盘着两腿，下面垫一个蒲包，用草绳在肩上… |
| 肩上 | jiānshàng / on the shoulder(s) | fix|artifact|肩|上 | 穿一件破夹袄，盘着两腿，下面垫一个蒲包，用草绳在肩上… |
| 仰面 | yǎngmiàn / face upturned, looking up | ok | 』孔乙己很颓唐的仰面答道，『这……下回还清罢。 |
| 答道 | dádào / to answer, replying (that...) | ok | 』孔乙己很颓唐的仰面答道，『这……下回还清罢。 |

