# xiyouji1 — compendium pipeline prototype report

Text: chapter 1 of 西游记 (Journey to the West, Ming dynasty c. 1592; vernacular novel prose mixed with classical verse), simplified, 3309 Han tokens, 1896 studyable words.
Lexicon stand-in: HSK 1–7 deck (flash-csvs). Sonnet proposes, Opus confirms.

## Coverage

| bucket | unique words | tokens | token share |
|---|---|---|---|
| in lexicon (HSK) | 591 | 1608 | 48.6% |
| new, CEDICT-grounded | 586 | 919 | 27.8% |
| not in CEDICT | 719 | 830 | 25.1% |
| pre-split artifacts (counts fan to parts) | 110 | 157 | 4.7% |

HSK words by level: L1: 90, L2: 53, L3: 57, L4: 89, L5: 86, L6: 75, L7: 141

## Pre-split (deterministic, verified)

110 artifact tokens split by rule: redup: 6, number: 71, suffix: 33.

**redup**: 渺渺→渺, 朗朗→朗, 片片→片, 般般→般, 念念→念, 走走→走

**number**: 百岁→岁, 每会→会, 一日→日, 五千四百岁→岁, 两间→间, 一阳→阳, 三才→才, 四大部→大部, 一座→座, 三岛→岛, 一条→条, 万劫→劫, 三丈→丈, 六尺→尺, 五寸→寸, 二丈→丈, 四尺→尺, 八孔→孔, 九宫→宫, 每受→受, 两道→道, 一卵→卵, 一石→石, 一朝→朝, 一群→群, 一股→股, 一派→派, 三声→声, 一纵→纵, 一架→架, 一竿→竿, 两竿→竿, 三点→点, 五点→点, 几树→树, 两个→个, 千百口→口, 每蒸→蒸, 千岁→岁, 百花→花, 五百载→载, 五虫→虫, 三等→等, 三者→者, 四瓣→瓣, 八九年→年, 千峰→峰, 万仞→仞, 一担→担, 三升→升, 二则→则, 八九岁→岁, 一人→人, 两束→束, 七八里→里, 千株→株, 万节→节, 每见→见, 九皋→皋, 八尺→尺, 十个→个, 两袖→袖, 一尘→尘, 一层层→层层, 一进→进, 三十个→个, 三三行→行, 一见→见, 两遍→遍, 万望→望, 十二个→个

**suffix**: 天中→天+中, 海中→海+中, 林中→林+中, 树上→树+上, 山上→山+上, 山中→山+中, 林下→林+下, 寻个→寻+个, 泉中→泉+中, 桥下→桥+下, 碣上→碣+上, 水外→水+外, 往里→往+里, 朝上→朝+上, 堕下→堕+下, 躲过→躲+过, 折些→折+些, 取个→取+个, 波中→波+中, 弄个→弄+个, 妆个→妆+个, 觅个→觅+个, 飘过→飘+过, 甚么→甚+么, 有个→有+个, 你了→你+了, 身下→身+下, 口中→口+中, 十数个→十数+个, 陪个→陪+个, 起个→起+个, 好么→好+么, 修些→修+些

## Phase A — match step (existing cards)

470/591 covered by the existing gloss. Of 121 proposed new senses, Opus confirmed 98, rejected 23.

| word | existing gloss | proposed new sense | confirm | sentence |
|---|---|---|---|---|
| 发明 | to invent; an invention | to bring forth, manifest, or make apparent | ok | 覆载群生仰至仁，发明万物皆成善。 |
| 岁 | years old | year (as a unit of time/duration, not age) | ok | 盖闻天地之数，有十二万九千六百岁为一元。 |
| 将 | will; shall | (preposition marking the object of a following verb, like "把") | ok | 将一元分为十二会，乃子、丑、寅、卯、辰、巳、午、未、… |
| 会 | to know how to; will; meeting | a unit of time in ancient cosmology (period within an epoch) | ok | 将一元分为十二会，乃子、丑、寅、卯、辰、巳、午、未、… |
| 丑 | ugly | second of the twelve Earthly Branches (calendar/zodiac sign) | ok | 将一元分为十二会，乃子、丑、寅、卯、辰、巳、午、未、… |
| 未 | not yet | eighth of the twelve Earthly Branches (calendar/zodiac sign) | ok | 将一元分为十二会，乃子、丑、寅、卯、辰、巳、午、未、… |
| 也 | also; too; as well; (not ...) either | (sentence-final particle marking a statement, like "is/are") | ok | 将一元分为十二会，乃子、丑、寅、卯、辰、巳、午、未、… |
| 且 | and; moreover; furthermore | now; for now (used to introduce a topic for discussion, not additive "and/moreover") | ok | 且就一日而论：子时得阳气，而丑则鸡鸣； |
| 就 | then; right away; just | with regard to; in terms of (introducing the basis for a discussion, as in 就...而论) | ok | 且就一日而论：子时得阳气，而丑则鸡鸣； |
| 子 | noun suffix | zi (the first of the Twelve Earthly Branches, naming a two-hour period) | ok | 且就一日而论：子时得阳气，而丑则鸡鸣； |
| 昏 | to faint | dim; obscure; not clear (of light/atmosphere, not fainting) | ok | 譬于大数，若到戌会之终，则天地昏曚而万物否矣。 |
| 去 | to go | to elapse; to pass (of time) | reject|metaphorical extension of taught "to go" (go/pass another 5,400 years), not a separate sense | 再去五千四百岁，交亥会之初，则当黑暗，而两间人物俱无… |
| 当 | to act as; when; to treat as; suitable; to pawn | shall; will surely be (auxiliary verb marking expected future state) | ok | 再去五千四百岁，交亥会之初，则当黑暗，而两间人物俱无… |
| 人物 | figure (of importance); character (in a story) | people and creatures; living beings in general (not a notable figure or story character) | ok | 再去五千四百岁，交亥会之初，则当黑暗，而两间人物俱无… |
| 开明 | enlightened | open and bright (of the sky/world becoming clear after chaos), not "enlightened" in the modern progressive-attitude sense | ok | 又五千四百岁，亥会将终，贞下起元，近子之会，而复逐渐… |
| 正当 | legitimate; proper | precisely at; exactly during (a given time period) | ok | 再五千四百岁，正当子会，轻清上腾，有日，有月，有星，… |
| 日 | day; day of the month | the sun (as a celestial body, listed alongside moon/stars) | ok | 再五千四百岁，正当子会，轻清上腾，有日，有月，有星，… |
| 元 | yuan (Chinese currency unit) | the primal/originating force (Yijing term for the generative power of Qian/Heaven) | ok | 《易》曰：“大哉乾元！ |
| 物资 | supplies | to rely on; to draw sustenance from (verb 资, not the modern noun "supplies") | reject|segmentation error: the word here is 万物 + 资生; 物资 does not occur, so this is a sense of 资, not of the card word | 万物资生，乃顺承天。 |
| 发生 | to happen | to generate; to bring into being (transitive "give birth to," not "to occur") | ok | 又经五千四百岁，丑会终而寅会之初，发生万物。 |
| 天气 | weather | vital energy/qi of the heavens (classical cosmological term, paired with earthly qi), not meteorological weather | ok | 历曰：“天气下降，地气上升； |
| 下降 | to decline | to descend; to move downward (physical direction, not deterioration/decrease) | ok | 历曰：“天气下降，地气上升； |
| 人生 | life (one's time on earth) | people were born (人 "people" + 生 "were born" — a verb phrase here, not the noun "life") | ok | 故曰，人生于寅。 |
| 感 | sense of ~ | in response to; following upon (classical verb introducing a clause, not the "sense of ~" suffix) | ok | 感盘古开辟，三皇治世，五帝定伦，世界之间，遂分为四大… |
| 表 | watch (timepiece); table; form; meter | to narrate; to relate (classical usage, as in a book's account) | ok | 这部书单表东胜神洲。 |
| 龙 | dragon | mountain ridge/vein said to carry the "dragon" energy of the land (feng shui term) | ok | 此山乃十洲之祖脉，三岛之来龙，自开清浊而立，鸿濛判后… |
| 每 | each | often; frequently (classical adverbial usage, not "each") | ok | 仙桃常结果，修竹每留云。 |
| 劫 | to rob; to hijack | kalpa: a vast cosmic age or eon (Buddhist term for an immense span of time) | ok | 正是百川会处擎天柱，万劫无移大地根。 |
| 气 | air; gas; to anger; to get angry | one of the 24 solar terms (solar-calendar divisions of the year), not air/gas/anger | ok | 二丈四尺围圆，按政历二十四气。 |
| 天真 | naive; innocent; artless | heaven's pure/genuine essence (classical cosmological sense, not the modern "naive") | ok | 盖自开辟以来，每受天真地秀，日精月华，感之既久，遂有… |
| 灵通 | fast and abundant (news) | spiritually aware; possessing sentient or magical understanding | ok | 盖自开辟以来，每受天真地秀，日精月华，感之既久，遂有… |
| 的 | of; ~'s (possessive particle) | particle marking the degree/result of a verb (equivalent to 得), not possessive "of" | ok | 二将果奉旨出门外，看的真，听的明。 |
| 回报 | to repay; to reciprocate; to return (a favor) | to report back; to bring word (not repay a favor) | ok | 须臾回报道：“臣奉旨观听金光之处，乃东胜神洲海东傲来… |
| 道 | road; way; classifier for rivers, walls, dishes, or questions | to say (introducing direct speech) | ok | 须臾回报道：“臣奉旨观听金光之处，乃东胜神洲海东傲来… |
| 来 | to come | part of a proper place name (Aolai), not the verb "to come" | reject|syllable in a transliterated place name (傲来), not a lexical sense of 来 | 须臾回报道：“臣奉旨观听金光之处，乃东胜神洲海东傲来… |
| 朝 | to face; towards | morning; day (as a time period, e.g. "one day") | ok | 一朝天气炎热，与群猴避暑，都在松阴之下顽耍。 |
| 跑 | to run; to run away; to escape | to paw or scrape at (like an animal digging in the ground) | ok | 跑沙窝，砌宝塔； |
| 蜡 | wax | part of an insect name (a cicada-like bug), not the wax substance | reject|bound morpheme in the insect name 𧈢蜡, not an independent sense of 蜡 | 赶蜻蜓，扑𧈢蜡； |
| 理 | reason; to manage; to pay attention to | to groom, comb, or tidy (fur/hair) | reject|grooming/tidying fur is covered by the taught "to manage; put in order" sense | 理毛衣，剔指甲。 |
| 毛衣 | sweater | fur; body hair (of an animal), not a knitted garment | ok | 理毛衣，剔指甲。 |
| 随 | to follow | as one likes; freely; at will | ok | 扯的扯，拉的拉：青松林下任他顽，绿水涧边随洗濯。 |
| 却 | however | then; thereupon (narrative connector, not contrastive "however") | ok | 一群猴子耍了一会，却去那山涧中洗澡。 |
| 直至 | lasting until | all the way to; right up to (reaching a place, not a time span) | ok | ”喊一声，都拖男挈女，呼弟呼兄，一齐跑来，顺涧爬山，… |
| 但 | but; yet (formal/written) | only; merely (introduces what is seen, as in "one could only see...") | ok | 但见那： |
| 派 | to dispatch; to send; faction | classifier for a stretch/expanse of scenery, light, sound, etc. | ok | 一派白虹起，千寻雪浪飞。 |
| 不断 | unceasing | cannot be broken/severed (resultative complement after a verb, not the adjective "unceasing") | ok | 海风吹不断，江月照还依。 |
| 依 | to depend on; to comply with; according to | to remain, linger, stay unchanged (like 依旧) | ok | 海风吹不断，江月照还依。 |
| 名 | name; place (in a ranking); classifier for people | to be called/named (verb: "X 名 Y" = X is called Y) | ok | 潺湲名瀑布，真似挂帘帷。 |
| 直接 | direct | to directly reach or connect to (border directly on something) | ok | 原来此处远通山脚之下，直接大海之波。 |
| 等 | to wait (for); etc.; and so on; class; grade | plural suffix attached after a pronoun (e.g. 我等 = "we/us") | ok | ”又道：“那一个有本事的，钻进去寻个源头出来，不伤身… |
| 连 | even; to link; to connect | in succession, repeatedly (before a verb + number of times) | ok | ”连呼了三声，忽见丛杂中跳出一个石猴，应声高叫道：“… |
| 明明 | obviously | bright; luminous (in a reduplicated descriptive phrase, not "obviously") | ok | 你看他瞑目蹲身，将身一纵，径跳入瀑布泉中，忽睁睛抬头… |
| 住 | to live; to stay | to stop; to halt (motion) | ok | 他住了身，定了神，仔细再看，原来是座铁板桥。 |
| 神 | god; deity; mysterious; (coll.) amazing | spirit; mind; composure | ok | 他住了身，定了神，仔细再看，原来是座铁板桥。 |
| 人家 | other people; I, me (when referring to oneself) | household; family home | ok | 却又欠身上桥头，再走再看，却似有人家住处一般，真个好… |
| 一般 | ordinary; so-so; general | alike; the same as (in similes with 似/好像) | ok | 却又欠身上桥头，再走再看，却似有人家住处一般，真个好… |
| 点 | (after a number) o'clock; a bit; o'clock; a bit; to order (food); to tap | a dot; spot (a scattered mark or point, as in clusters of blossoms) | ok | 又见那一竿两竿修竹，三点五点梅花。 |
| 一行 | traveling party; delegation | a line (of writing/text) | ok | 只见正当中有一石碣，碣上有一行楷书大字，镌著“花果山… |
| 急 | urgent; worried; to make (sb) anxious | hastily; quickly (in a hurry) | reject|adverbial use of the taught "urgent" sense, not a new meaning | 石猿喜不自胜，急抽身往外便走，复瞑目蹲身，跳出水外，… |
| 打 | to hit; to strike; to play; from; since (colloquial) | to do/make (light verb use, e.g. with sound words like laughing) | ok | 石猿喜不自胜，急抽身往外便走，复瞑目蹲身，跳出水外，… |
| 缠 | to wind around; to pester | to dawdle around; to carry on for a while (before acting) | reject|"fuss/carry on a while" is covered by the taught "to pester" | 胆小的，一个个伸头缩颈，抓耳挠腮，大声叫喊，缠一会，… |
| 得力 | capable | segmentation error here: 得 is a verb complement on 搬 ("moved until..."), not the word 得力 | ok | 跳过桥头，一个个抢盆夺碗，占灶争床，搬过来，移过去，… |
| 呵 | to scold | sentence-final exclamatory particle (like 啊), not "to scold" | ok | 石猿端坐上面道：“列位呵，‘人而无信，不知其可。 |
| 成家 | to settle down and get married (of a man) | to establish a home/settle down (not specifically marriage) | reject|same act of establishing a household; only a nuance on the marriage part | 我如今进来又出去，出去又进来，寻了这一个洞天与列位安… |
| 拱 | to arch | to clasp hands in salute/bow (gesture of respect or submission) | ok | ”众猴听说，即拱伏无违，一个个序齿排班，朝上礼拜，都… |
| 精 | refined; skilled; excellent; elite | vital essence/energy (a distilled life-force, not "refined/skilled/elite") | ok | 三阳交泰产群生，仙石胞含日月精。 |
| 假 | fake | to borrow/make use of (as in 假借), not "fake" | ok | 借卵化猴完大道，假他名姓配丹成。 |
| 同情 | to sympathize with | of one mind; sharing the same feelings/temperament (classical sense, not modern "sympathize") | ok | 朝游花果山，暮宿水帘洞，合契同情，不入飞鸟之丛，不从… |
| 从 | from | to follow; to associate with | ok | 朝游花果山，暮宿水帘洞，合契同情，不入飞鸟之丛，不从… |
| 生涯 | career | livelihood; a way of getting by (not a professional "career") | ok | 春采百花为饮食，夏寻诸果作生涯。 |
| 精度 | precision | to pass; to spend (time) — segmentation artifact, real sense belongs to 度 here, not "precision" | reject|segmentation artifact — 精度 doesn't occur (黄精 + 度岁华); proposed gloss belongs to 度, not a sense of this word | 秋收芋栗延时节，冬觅黄精度岁华。 |
| 不得 | must not | unable to; cannot (expresses inability, not prohibition) | ok | ”猴王道：“今日虽不归人王法律，不惧禽兽威严，将来年… |
| 开发 | to develop; to exploit (a resource) | to open up, awaken (the mind/heart) | ok | 只见那班部中，忽跳出一个通背猿猴，厉声高叫道：“大王… |
| 神圣 | sacred | a divine being; a sage (a class of immortal-like beings) | ok | ”猿猴道：“乃是佛与仙与神圣三者，躲过轮回，不生不灭… |
| 居于 | to occupy (a position); to rank | to reside in; to be located at | ok | ”猴王道：“此三者居于何所？ |
| 浮 | to float | part of a phonetic transliteration naming the mortal human world (Jambudvipa); not the literal meaning | ok | ”猿猴道：“他只在阎浮世界之中，古洞仙山之内。 |
| 难 | difficult | disaster; calamity; hardship (noun) | ok | ”猴王闻之，满心欢喜道：“我明日就辞汝等下山，云游海… |
| 成 | one tenth (10%) | to become | ok | 这句话，顿教跳出轮回网，致使齐天大圣成。 |
| 弹 | to play (a string instrument); to flick | pellet; small round shot (noun, as in fruit shaped like pellets) | ok | 金丸珠弹，红绽黄肥。 |
| 教 | to teach | to tell/order (someone to do something); causative "make/let" | ok | 次日，美猴王早起，教：“小的们，替我折些枯松，编作筏… |
| 愿 | to be willing; to wish | a wish; desire (used as a noun) | reject|noun use of the taught verb sense "to wish" — grammatical variation, not a new sense | 有分有缘休俗愿，无忧无虑会元龙。 |
| 紧 | tight; tense; urgent | strong, brisk (describing wind blowing hard) | reject|风紧 is a nuance of the taught "tense; urgent" (intensity), not a separate sense | 也是他运至时来，自登木筏之后，连日东南风紧，将他送到… |
| 淘 | to wash (rice) | to extract by panning/washing (e.g., harvesting salt from sand) | reject|panning salt is the same core "wash/rinse out" action already taught by "to wash (rice)" | 只见海边有人捕鱼、打雁、穵蛤、淘盐。 |
| 丢 | to lose | to throw down; toss aside; drop | ok | 他走近前，弄个把戏，妆个𡤫虎，吓得那些人丢筐弃网，四… |
| 中学 | middle school | in, amid, within (a place) — not the compound "middle school"; 学 here is a separate word meaning "to learn" | reject|segmentation artifact — 中学 doesn't occur (市廛中 + 学人礼); proposed gloss belongs to 中, not a sense of this word | 摇摇摆摆，穿州过府，在市廛中学人礼，学人话。 |
| 访问 | to visit; to call on (a person or place) | to seek out; search for (a path, teaching, or ideal) | ok | 朝餐夜宿，一心里访问佛、仙、神圣之道，觅个长生不老之… |
| 勾 | to attract; to arouse; to outline; to collude | to summon or fetch away a soul (to the underworld); to arrest | ok | 只愁衣食耽劳碌，何怕阎君就取勾。 |
| 在于 | to lie in; to depend on | to be located in; situated at | ok | 在于南赡部洲，串长城，游小县，不觉八九年馀。 |
| 串 | string; bunch; skewer; classifier for strung or bunched items | to travel through; to wander from place to place | ok | 在于南赡部洲，串长城，游小县，不觉八九年馀。 |
| 松 | loose; to loosen; to relax | pine tree | ok | 奇花瑞草，修竹乔松。 |
| 间 | classifier for rooms | while; during (the time when) | ok | 正观看间，忽闻得林深之处有人言语。 |
| 言语 | words | to speak; to talk | reject|noun "words" → verb "to speak" is a transparent part-of-speech shift, not a new sense | 正观看间，忽闻得林深之处有人言语。 |
| 打扮 | to dress up; to make up | attire; appearance; the way one is dressed | reject|noun "attire" is the transparent nominalization of the taught verb "to dress up" | 但看他打扮非常： |
| 非常 | very | extraordinary; unusual | ok | 但看他打扮非常： |
| 不当 | inappropriate | humble phrase declining a compliment, roughly "I don't deserve this" | reject|polite formulaic use of the taught meaning "improper/undeserved"; register shift only | ”那樵汉慌忙丢了斧，转身答礼道：“不当人，不当人。 |
| 的话 | if (coming after a conditional clause) | words; what was said (possessive 的 + 话, not the conditional "if" construction) | ok | ”猴王道：“你不是神仙，如何说出神仙的话来？ |
| 道德 | morality | the Dao and its virtue (Daoist philosophical term, not everyday ethics) | ok | ’《黄庭》乃道德真言，非神仙而何？ |
| 蒙 | to deceive; to make a wild guess; to cover; ignorant | to receive a kindness from someone; to be favored with (humble/polite verb) | ok | ”樵夫道：“我一生命苦：自幼蒙父母养育至八九岁，才知… |
| 人事 | personnel | to understand the ways of the world; to reach maturity | ok | ”樵夫道：“我一生命苦：自幼蒙父母养育至八九岁，才知… |
| 货 | goods; cargo (stock or freight) | to sell; to peddle (goods) for money | ok | 却又田园荒芜，衣食不足，只得斫两束柴薪，挑向市廛之间… |
| 起来 | to stand up; to get up | used after a verb (e.g. 说起来) to mean "speaking of it, to judge by what's said" | ok | 猴王道：“据你说起来，乃是一个行孝的君子，向后必有好… |
| 得了 | all right!; that's enough! | to get, obtain (something desired or beneficial) | ok | ”猴王用手扯住樵夫道：“老兄，你便同我去去，若还得了… |
| 去处 | destination | a place, spot (general location being admired, not a travel destination) | ok | 挺身观看，真好去处！ |
| 灵 | effective; spirit | magical; numinous; sacred (of a place, spiritually charged) | reject|"numinous/sacred" falls within the taught "spirit; effective" range | 细观灵福地，真个赛天堂。 |
| 呀 | ah (used to express surprise) | creak (onomatopoeia for a door/object sound, not surprise) | ok | 少顷间，只听得呀的一声，洞门开处，里面走出一个仙童，… |
| 整 | whole; entire | to tidy up or straighten (clothing) | ok | 这猴王整衣端肃，随童子径入洞天深处观看：一层层深阁琼… |
| 行 | to walk; to go; OK; all right; row; trade; classifier for rows or lines | conduct; (spiritual/religious) practice or deeds | ok | 不生不灭三三行，全气全神万万慈。 |
| 万万 | absolutely (before negatives) | utterly; boundlessly (intensifier, not tied to negation) | ok | 不生不灭三三行，全气全神万万慈。 |
| 修 | to repair; to build; to take (a class) | to cultivate (spiritual practice, toward enlightenment) | ok | 他本是个撒诈捣虚之徒，那里修甚么道果！ |
| 重大 | major; significant; important | layer; fold (measure word for stacked things, as in 两重 "two layers") | reject|segmentation artifact — the word here is 两重 + 大海; 重大 is not a unit in this sentence | 那去处到我这里隔两重大海，一座南赡部洲，如何就得到此… |
| 得到 | to obtain | to reach; to arrive at (a place) | reject|segmentation artifact — 得 + 到此; the "arrive" meaning belongs to 到, not to a 得到 unit | 那去处到我这里隔两重大海，一座南赡部洲，如何就得到此… |
| 陪 | to accompany | to make (an apology), as in 陪礼 "to apologize" | ok | 只是陪个礼儿就罢了。 |
| 个性 | personality | temperament; temper; disposition (character trait, wordplay on 性 vs 姓) | reject|segmentation artifact — 这个 + 性; and "temperament" is a nuance of the taught "personality" | ”祖师道：“不是这个性。 |
| 拐 | to turn (a corner); to kidnap | to walk with a wobble/limp; to sway side to side (mimetic, as in 拐呀拐地) | ok | ”猴王纵身跳起，拐呀拐的走了两遍。 |
| 阴 | overcast (weather) | yin (the dark/feminine principle in yin-yang cosmology) | ok | 月者，阴也。 |
| 个子 | stature; height; size (of a person or object) | a; one (generic classifier 个, unrelated to the "stature/height" compound) | reject|segmentation artifact — 个 + 子系; proposal only corrects the split, gives no new sense of 个子 | 狲字去了兽傍，乃是个子系。 |
| 系 | to tie; department; faculty | connecting thread; lineage (the 系 character component/radical, not "department" or "to tie") | reject|character quoted as a leftover graph component, not used in a "lineage" sense here | 狲字去了兽傍，乃是个子系。 |
| 门 | gate; door; doorway; gateway; opening | school; sect; order of disciples (lineage), not a physical gate | ok | ”祖师道：“我门中有十二个字，分派起名，到你乃第十辈… |
| 如 | as; such as | "suchness"/true reality — the nature of things as they truly are (Buddhist term, as in 真如) | reject|"suchness" belongs to the bound compound 真如; 如 alone in the name list carries no such standalone sense | ”祖师道：“乃广、大、智、慧、真、如、性、海、颖、悟… |
| 性 | (noun suffix: -ness, -ity) | (inherent) nature; the mind's true nature (Buddhist term, as in 性海) | ok | ”祖师道：“乃广、大、智、慧、真、如、性、海、颖、悟… |
| 圆 | round; circular; circle | complete; perfect; whole (spiritual perfection, as in 圆觉) | ok | ”祖师道：“乃广、大、智、慧、真、如、性、海、颖、悟… |

## Phase B — new words glossed against CEDICT (50 fixed by confirm)

### word (532)

| word | verdict | confirm | sentence |
|---|---|---|---|
| 诗曰 | shī yuē / A poem goes: — a stock phrase introducing a poem. | ok | 诗曰： |
| 混沌 | hùn dùn / Primal chaos — the undifferentiated state of the universe before heaven and earth existed. | ok | 混沌未分天地乱，茫茫渺渺无人见。 |
| 渺 | miǎo / Vast and hazy; distant and indistinct. | ok | 混沌未分天地乱，茫茫渺渺无人见。 |
| 无人 | wú rén / No one; nobody (there was no one to see it). | ok | 混沌未分天地乱，茫茫渺渺无人见。 |
| 辨 | biàn / To distinguish; tell apart. | ok | 自从盘古破鸿濛，开辟从兹清浊辨。 |
| 造化 | zào huà / Nature, or the Creator — the cosmic force that shapes the world (literary). | ok | 欲知造化会元功，须看《西游释厄传》。 |
| 一元 | yī yuán / One cosmic cycle — a vast unit of time (129,600 years) in traditional Chinese cosmology. | ok | 盖闻天地之数，有十二万九千六百岁为一元。 |
| 十二 | shí èr / Twelve. | ok | 将一元分为十二会，乃子、丑、寅、卯、辰、巳、午、未、… |
| 寅 | yín / Yin — the 3rd Earthly Branch, corresponding to 3–5 a.m. | ok | 将一元分为十二会，乃子、丑、寅、卯、辰、巳、午、未、… |
| 卯 | mǎo / Mao — the 4th Earthly Branch, corresponding to 5–7 a.m. | ok | 将一元分为十二会，乃子、丑、寅、卯、辰、巳、午、未、… |
| 辰 | chén / Chen — the 5th Earthly Branch, corresponding to 7–9 a.m. | ok | 将一元分为十二会，乃子、丑、寅、卯、辰、巳、午、未、… |
| 巳 | sì / Si — the 6th Earthly Branch, corresponding to 9–11 a.m. | ok | 将一元分为十二会，乃子、丑、寅、卯、辰、巳、午、未、… |
| 午 | wǔ / Wu — the 7th Earthly Branch, corresponding to 11 a.m.–1 p.m. (noon). | ok | 将一元分为十二会，乃子、丑、寅、卯、辰、巳、午、未、… |
| 申 | shēn / Shen — the 9th Earthly Branch, corresponding to 3–5 p.m. | ok | 将一元分为十二会，乃子、丑、寅、卯、辰、巳、午、未、… |
| 酉 | yǒu / You — the 10th Earthly Branch, corresponding to 5–7 p.m. | ok | 将一元分为十二会，乃子、丑、寅、卯、辰、巳、午、未、… |
| 戌 | xū / Xu — the 11th Earthly Branch, corresponding to 7–9 p.m. | ok | 将一元分为十二会，乃子、丑、寅、卯、辰、巳、午、未、… |
| 亥 | hài / Hai — the 12th Earthly Branch, corresponding to 9–11 p.m. | ok | 将一元分为十二会，乃子、丑、寅、卯、辰、巳、午、未、… |
| 十二支 | shí èr zhī / The twelve Earthly Branches — cyclical terms used to mark time in the traditional calendar. | ok | 将一元分为十二会，乃子、丑、寅、卯、辰、巳、午、未、… |
| 不通 | bù tōng / Not yet coming through; blocked (here, of daylight not yet penetrating). | ok | 寅不通光，而卯则日出； |
| 日出 | rì chū / sunrise | ok | 寅不通光，而卯则日出； |
| 辰时 | chén shí / the two-hour period from 7-9 am | ok | 辰时食后，而巳则挨排； |
| 蹉 | cuō / to slip past, decline (the sun edging past its peak) | ok | 日午天中，而未则西蹉； |
| 申时 | shēn shí / the two-hour period from 3-5 pm | ok | 申时晡，而日落酉，戌黄昏，而人定亥。 |
| 晡 | bū / late afternoon, roughly 3-5 pm | ok | 申时晡，而日落酉，戌黄昏，而人定亥。 |
| 日落 | rì luò / sunset | ok | 申时晡，而日落酉，戌黄昏，而人定亥。 |
| 大数 | dà shù / a rough count; broad estimate (speaking in general terms) | fix|word|dà shù|the grand reckoning; the great cosmic cycle of numbers | 譬于大数，若到戌会之终，则天地昏曚而万物否矣。 |
| 曚 | méng / dim, hazy (murky half-light) | ok | 譬于大数，若到戌会之终，则天地昏曚而万物否矣。 |
| 俱 | jù / all, entirely, without exception | ok | 再去五千四百岁，交亥会之初，则当黑暗，而两间人物俱无… |
| 终 | zhōng / to end, come to a close | ok | 又五千四百岁，亥会将终，贞下起元，近子之会，而复逐渐… |
| 冬至 | dōng zhì / Winter Solstice, one of the 24 solar terms | ok | 邵康节曰：“冬至子之半，天心无改移。 |
| 天心 | tiān xīn / the heart/center of Heaven; the will of Heaven | ok | 邵康节曰：“冬至子之半，天心无改移。 |
| 阳 | yáng / yang, the positive/active principle in Chinese cosmology | ok | 一阳初动处，万物未生时。 |
| 星 | xīng / star | ok | 日、月、星、辰，谓之四象。 |
| 四象 | sì xiàng / the Four Symbols, groupings of the 28 constellations in Chinese astronomy | fix|word|sì xiàng|the Four Images: sun, moon, stars, and constellations | 日、月、星、辰，谓之四象。 |
| 哉 | zāi / exclamatory particle: "how ...!", "indeed!" | ok | 《易》曰：“大哉乾元！ |
| 凝 | níng / to congeal, solidify | ok | 再五千四百岁，正当丑会，重浊下凝，有水，有火，有山，… |
| 石 | shí / Stone (one of the five basic elements/phases, along with water, fire, mountain, and earth). | ok | 水、火、山、石、土，谓之五形。 |
| 五形 | wǔ xíng / The five elements/phases (here: water, fire, mountain, stone, earth — a cosmological framework). | ok | 水、火、山、石、土，谓之五形。 |
| 交合 | jiāo hé / To join together, unite (of heaven and earth merging to bring forth life). | ok | 天地交合，群物皆生。 |
| 阴阳 | yīn yáng / Yin and yang, the two complementary cosmic forces. | ok | ”至此，天清地爽，阴阳交合。 |
| 生人 | shēng rén / To give birth to humans (born of the union of heaven and earth). | fix|artifact|shēng rén|Bad segmentation — here 生 "to produce" takes 人 as its object, parallel to 生兽/生禽; the dictionary word 生人 ("stranger; living person") is not present. | 再五千四百岁，正当寅会，生人，生兽，生禽，正谓天地人… |
| 遂 | suì / Thereupon, then (marks the next event in a sequence). | ok | 感盘古开辟，三皇治世，五帝定伦，世界之间，遂分为四大… |
| 大部 | dà bù / The greater part, most (of something). | fix|artifact|dà bù|Bad segmentation — the phrase is 四 + 大部洲, where 部洲 is the Buddhist term for "continent"; 大部 "the greater part" is not a unit here. | 感盘古开辟，三皇治世，五帝定伦，世界之间，遂分为四大… |
| 洲 | zhōu / Continent (one of the four great continents of the world). | ok | 感盘古开辟，三皇治世，五帝定伦，世界之间，遂分为四大… |
| 赡 | shàn / To sustain, support, provide for (part of the continent name "South Jambu Continent that sustains/supports"). | fix|word|shàn|To support, provide for; here purely phonetic, transcribing "Jambu" in 南赡部洲 (Jambudvipa, the Southern Continent). | 感盘古开辟，三皇治世，五帝定伦，世界之间，遂分为四大… |
| 大海 | dà hǎi / The sea, the ocean. | ok | 国近大海，海中有一座名山，唤为花果山。 |
| 名山 | míng shān / A famous mountain. | ok | 国近大海，海中有一座名山，唤为花果山。 |
| 鸿 | hóng / Vast, great (describing the primordial mist/chaos before creation). | ok | 此山乃十洲之祖脉，三岛之来龙，自开清浊而立，鸿濛判后… |
| 真个 | zhēn gè / Truly, really, indeed (emphasizing the following description). | ok | 真个好山！ |
| 潮涌 | cháo yǒng / to surge like a tide (powerful, cresting waves) | ok | 势镇汪洋，潮涌银山鱼入穴； |
| 麒麟 | qí lín / qilin, a mythical hoofed creature (auspicious dragon-like beast) | ok | 削壁前，麒麟独卧。 |
| 石窟 | shí kū / rock cave; grotto in a cliff face | ok | 峰头时听锦鸡鸣，石窟每观龙出入。 |
| 不谢 | bù xiè / never withers or fades (of flowers and plants) | ok | 瑶草奇花不谢，青松翠柏长春。 |
| 青松 | qīng sōng / pine tree | ok | 瑶草奇花不谢，青松翠柏长春。 |
| 长春 | cháng chūn / ever springlike; evergreen, never fading | ok | 瑶草奇花不谢，青松翠柏长春。 |
| 仙桃 | xiān táo / peach of immortality, the magic fruit of the Queen Mother of the West | ok | 仙桃常结果，修竹每留云。 |
| 涧 | jiàn / mountain stream | ok | 一条涧壑藤萝密，四面原堤草色新。 |
| 壑 | hè / ravine; gully | ok | 一条涧壑藤萝密，四面原堤草色新。 |
| 四面 | sì miàn / on all sides; all around | ok | 一条涧壑藤萝密，四面原堤草色新。 |
| 正是 | zhèng shì / is precisely; just so (introduces a poetic couplet) | ok | 正是百川会处擎天柱，万劫无移大地根。 |
| 百川 | bǎi chuān / the hundred rivers; all rivers | ok | 正是百川会处擎天柱，万劫无移大地根。 |
| 顶上 | dǐng shàng / at the very top; at the summit | ok | 那座山正当顶上，有一块仙石。 |
| 一块 | yī kuài / a piece (of); a chunk (of) | ok | 那座山正当顶上，有一块仙石。 |
| 丈 | zhàng / zhang, a unit of length, about 3.3 meters | ok | 其石有三丈六尺五寸高，有二丈四尺围圆。 |
| 周天 | zhōu tiān / one full circuit of the heavens (360 degrees, ancient astronomy) | ok | 三丈六尺五寸高，按周天三百六十五度； |
| 九窍 | jiǔ qiào / the nine orifices of the body (eyes, ears, nostrils, mouth, etc.) | ok | 上有九窍八孔，按九宫八卦。 |
| 遮阴 | zhē yīn / to give shade; to block the sun | ok | 四面更无树木遮阴，左右倒有芝兰相衬。 |
| 芝兰 | zhī lán / fragrant orchids; elegant flowering plants adorning a scene | ok | 四面更无树木遮阴，左右倒有芝兰相衬。 |
| 相衬 | xiāng chèn / to set off each other; to complement nicely | ok | 四面更无树木遮阴，左右倒有芝兰相衬。 |
| 月华 | yuè huá / moonlight | ok | 盖自开辟以来，每受天真地秀，日精月华，感之既久，遂有… |
| 迸裂 | bèng liè / to burst open; to split apart | ok | 内育仙胞，一日迸裂，产一石卵，似圆球样大。 |
| 似 | sì / to resemble; to look like | ok | 内育仙胞，一日迸裂，产一石卵，似圆球样大。 |
| 圆球 | yuán qiú / a round ball; sphere | ok | 内育仙胞，一日迸裂，产一石卵，似圆球样大。 |
| 化作 | huà zuò / to transform into; to become | ok | 因见风，化作一个石猴，五官俱备，四肢皆全。 |
| 一个 | yī ge / a; one (generic classifier) | ok | 因见风，化作一个石猴，五官俱备，四肢皆全。 |
| 拜 | bài / to bow; to pay respects | ok | 便就学爬学走，拜了四方。 |
| 宝殿 | bǎo diàn / a grand throne hall; palace hall | ok | 惊动高天上圣大慈仁者玉皇大天尊玄穹高上帝，驾座金阙云… |
| 金 | jīn / golden; gold (describing the gate towers) | ok | 惊动高天上圣大慈仁者玉皇大天尊玄穹高上帝，驾座金阙云… |
| 焰 | yàn / blazing; flame-like (reduplicated for radiance) | ok | 惊动高天上圣大慈仁者玉皇大天尊玄穹高上帝，驾座金阙云… |
| 奉旨 | fèng zhǐ / acting on imperial orders | ok | 二将果奉旨出门外，看的真，听的明。 |
| 明 | míng / clearly; distinctly | ok | 二将果奉旨出门外，看的真，听的明。 |
| 须臾 | xū yú / in a moment; in a flash | ok | 须臾回报道：“臣奉旨观听金光之处，乃东胜神洲海东傲来… |
| 臣 | chén / I, your subject (term an official uses addressing the ruler) | ok | 须臾回报道：“臣奉旨观听金光之处，乃东胜神洲海东傲来… |
| 风化 | fēng huà / to be transformed by exposure to the wind (of the stone egg) | fix|artifact|fēng huà|mis-segmentation: the text reads 见风 + 化 ("on meeting the wind, [it] transformed"); 风化 is not a word here | 须臾回报道：“臣奉旨观听金光之处，乃东胜神洲海东傲来… |
| 猴 | hóu / monkey | ok | 须臾回报道：“臣奉旨观听金光之处，乃东胜神洲海东傲来… |
| 下方 | xià fāng / the world below; the mortal realm | ok | ”玉帝垂赐恩慈曰：“下方之物，乃天地精华所生，不足为… |
| 食 | shí / to eat | ok | 那猴在山中，却会行走跳跃，食草木，饮涧泉，采山花，觅… |
| 草木 | cǎo mù / plants; vegetation | ok | 那猴在山中，却会行走跳跃，食草木，饮涧泉，采山花，觅… |
| 之下 | zhī xià / beneath; under | ok | 夜宿石崖之下，朝游峰洞之中。 |
| 甲子 | jiǎ zǐ / the sixty-year calendar cycle; here used to mean "track of time" | ok | 真是：“山中无甲子，寒尽不知年。 |
| 不知 | bù zhī / not to know; unaware of | ok | 真是：“山中无甲子，寒尽不知年。 |
| 一个个 | yī gè gè / each one; one by one | ok | 你看他一个个： |
| 采花 | cǎi huā / to pick flowers | ok | 跳树攀枝，采花觅果； |
| 弹子 | dàn zi / small pellets or marbles (thrown in a children's game) | ok | 抛弹子，邷么儿； |
| 砌 | qì / to build by stacking (bricks, stones, or here sand) | ok | 跑沙窝，砌宝塔； |
| 宝塔 | bǎo tǎ / pagoda | ok | 跑沙窝，砌宝塔； |
| 蜻蜓 | qīng tíng / dragonfly | ok | 赶蜻蜓，扑𧈢蜡； |
| 参 | cān / to pay respects to; to worship (a deity) | ok | 参老天，拜菩萨； |
| 老天 | lǎo tiān / Heaven, God — invoked in prayer or worship | fix|word|lǎo tiān|Heaven; God | 参老天，拜菩萨； |
| 葛藤 | gé téng / tangled vines, vine tendrils (gathered for weaving) | fix|word|gé téng|kudzu vines; creeping vines | 扯葛藤，编草帓； |
| 虱子 | shī zi / louse | ok | 捉虱子，咬又掐； |
| 剔 | tī / to pick clean, scrape out (e.g. dirt from under nails) | ok | 理毛衣，剔指甲。 |
| 顽 | wán / to play, frolic, roam freely | ok | 扯的扯，拉的拉：青松林下任他顽，绿水涧边随洗濯。 |
| 绿水 | lǜ shuǐ / clear green water | ok | 扯的扯，拉的拉：青松林下任他顽，绿水涧边随洗濯。 |
| 洗濯 | xǐ zhuó / to wash, bathe | ok | 扯的扯，拉的拉：青松林下任他顽，绿水涧边随洗濯。 |
| 一会 | yī huì / a while, a short time | ok | 一群猴子耍了一会，却去那山涧中洗澡。 |
| 山涧 | shān jiàn / mountain stream | ok | 一群猴子耍了一会，却去那山涧中洗澡。 |
| 涧水 | jiàn shuǐ / stream water | ok | 见那股涧水奔流，真个似滚瓜涌溅。 |
| 奔流 | bēn liú / to rush, flow swiftly (of a current) | ok | 见那股涧水奔流，真个似滚瓜涌溅。 |
| 禽 | qín / birds (literary) | ok | 古云：“禽有禽言，兽有兽语。 |
| 言 | yán / speech, language | ok | 古云：“禽有禽言，兽有兽语。 |
| 兽 | shòu / beasts, animals | ok | 古云：“禽有禽言，兽有兽语。 |
| 众 | zhòng / all of, the whole crowd of | ok | ”众猴都道：“这股水不知是那里的水。 |
| 源流 | yuán liú / source, origin (of a stream) | ok | 我们今日赶闲无事，顺涧边往上溜头寻看源流，耍子去耶！ |
| 耍子 | shuǎ zi / to play, have fun | ok | 我们今日赶闲无事，顺涧边往上溜头寻看源流，耍子去耶！ |
| 爬山 | pá shān / to climb a mountain, hike | ok | ”喊一声，都拖男挈女，呼弟呼兄，一齐跑来，顺涧爬山，… |
| 乃是 | nǎi shì / turned out to be, was in fact | ok | ”喊一声，都拖男挈女，呼弟呼兄，一齐跑来，顺涧爬山，… |
| 海风 | hǎi fēng / sea breeze | ok | 海风吹不断，江月照还依。 |
| 馀 | yú / leftover; remaining (of flowing water) | fix|word|yú|remaining; surplus | 冷气分青嶂，馀流润翠微。 |
| 帷 | wéi / curtain; hanging screen | ok | 潺湲名瀑布，真似挂帘帷。 |
| 拍手 | pāi shǒu / to clap one's hands | ok | 众猴拍手称扬道：“好水，好水！ |
| 称扬 | chēng yáng / to praise; to exclaim in admiration | ok | 众猴拍手称扬道：“好水，好水！ |
| 此处 | cǐ chù / this place; here | ok | 原来此处远通山脚之下，直接大海之波。 |
| 山脚 | shān jiǎo / the foot of a mountain | ok | 原来此处远通山脚之下，直接大海之波。 |
| 王 | wáng / king; ruler | ok | ”又道：“那一个有本事的，钻进去寻个源头出来，不伤身… |
| 跳出 | tiào chū / to jump out; to spring out | ok | ”连呼了三声，忽见丛杂中跳出一个石猴，应声高叫道：“… |
| 应声 | yìng shēng / to respond immediately (to a call), answering as one speaks | ok | ”连呼了三声，忽见丛杂中跳出一个石猴，应声高叫道：“… |
| 叫道 | jiào dào / to cry out; to shout | ok | ”连呼了三声，忽见丛杂中跳出一个石猴，应声高叫道：“… |
| 有缘 | yǒu yuán / to be fated (to); destined by affinity | ok | 有缘居此地，王遣入仙宫。 |
| 居 | jū / to live; to reside | ok | 有缘居此地，王遣入仙宫。 |
| 此地 | cǐ dì / this place; here | ok | 有缘居此地，王遣入仙宫。 |
| 仙宫 | xiān gōng / palace of the immortals; heavenly palace | ok | 有缘居此地，王遣入仙宫。 |
| 瞑目 | míng mù / to close one's eyes | ok | 你看他瞑目蹲身，将身一纵，径跳入瀑布泉中，忽睁睛抬头… |
| 纵 | zòng / to leap; to spring up | ok | 你看他瞑目蹲身，将身一纵，径跳入瀑布泉中，忽睁睛抬头… |
| 径 | jìng / straightaway; directly | ok | 你看他瞑目蹲身，将身一纵，径跳入瀑布泉中，忽睁睛抬头… |
| 泉 | quán / spring; fount (of water) | ok | 你看他瞑目蹲身，将身一纵，径跳入瀑布泉中，忽睁睛抬头… |
| 无水 | wú shuǐ / without water; waterless | ok | 你看他瞑目蹲身，将身一纵，径跳入瀑布泉中，忽睁睛抬头… |
| 朗 | lǎng / bright and clear | ok | 你看他瞑目蹲身，将身一纵，径跳入瀑布泉中，忽睁睛抬头… |
| 倒挂 | dào guà / to hang upside down (here: water pouring down inverted, like an inverted cascade) | fix|word|dào guà|to hang upside down | 桥下之水，冲贯于石窍之间，倒挂流出去，遮闭了桥门。 |
| 欠身 | qiàn shēn / to rise up and lean forward (a bodily motion, here: pulling himself up onto the bridge) | fix|word|qiàn shēn|to raise oneself up slightly | 却又欠身上桥头，再走再看，却似有人家住处一般，真个好… |
| 桥头 | qiáo tóu / the end/head of a bridge | ok | 却又欠身上桥头，再走再看，却似有人家住处一般，真个好… |
| 白云 | bái yún / white cloud | ok | 翠藓堆蓝，白云浮玉，光摇片片烟霞。 |
| 烟霞 | yān xiá / mist and clouds; hazy scenic vapors | fix|word|yān xiá|mist and rosy clouds | 翠藓堆蓝，白云浮玉，光摇片片烟霞。 |
| 板 | bǎn / board; slab (of stone) | fix|word|bǎn|board; plank; slab | 虚窗静室，滑凳板生花。 |
| 萦回 | yíng huí / to swirl around; to linger | ok | 乳窟龙珠倚挂，萦回满地奇葩。 |
| 奇葩 | qí pā / exotic/rare flower | ok | 乳窟龙珠倚挂，萦回满地奇葩。 |
| 锅灶 | guō zào / cooking stove; hearth | ok | 锅灶傍崖存火迹，樽罍靠案见殽渣。 |
| 樽 | zūn / wine goblet | ok | 锅灶傍崖存火迹，樽罍靠案见殽渣。 |
| 罍 | léi / large wine jar | ok | 锅灶傍崖存火迹，樽罍靠案见殽渣。 |
| 竿 | gān / stalk/pole (counter for bamboo stems) | ok | 又见那一竿两竿修竹，三点五点梅花。 |
| 浑然 | hún rán / completely; entirely | ok | 几树青松常带雨，浑然像个人家。 |
| 罢 | bà / to finish; to stop (doing something) | fix|word|bà|to finish (after a verb: once done) | 看罢多时，跳过桥中间，左右观看。 |
| 只见 | zhǐ jiàn / then he saw; his eyes fell on | fix|word|zhǐ jiàn|suddenly one sees; there before him was | 只见正当中有一石碣，碣上有一行楷书大字，镌著“花果山… |
| 碣 | jié / stone tablet | ok | 只见正当中有一石碣，碣上有一行楷书大字，镌著“花果山… |
| 楷书 | kǎi shū / regular script (a calligraphy style) | ok | 只见正当中有一石碣，碣上有一行楷书大字，镌著“花果山… |
| 福地 | fú dì / blessed land; paradise | ok | 只见正当中有一石碣，碣上有一行楷书大字，镌著“花果山… |
| 洞天 | dòng tiān / a heavenly grotto; paradise (Daoist term for a sacred dwelling place) | ok | 只见正当中有一石碣，碣上有一行楷书大字，镌著“花果山… |
| 喜不自胜 | xǐ bù zì shèng / overjoyed; unable to contain one's joy | ok | 石猿喜不自胜，急抽身往外便走，复瞑目蹲身，跳出水外，… |
| 抽身 | chōu shēn / to withdraw oneself; to slip away | ok | 石猿喜不自胜，急抽身往外便走，复瞑目蹲身，跳出水外，… |
| 往外 | wǎng wài / outward; toward the outside | ok | 石猿喜不自胜，急抽身往外便走，复瞑目蹲身，跳出水外，… |
| 复 | fù / again; once more | ok | 石猿喜不自胜，急抽身往外便走，复瞑目蹲身，跳出水外，… |
| 呵呵 | hē hē / haha (sound of laughter) | ok | 石猿喜不自胜，急抽身往外便走，复瞑目蹲身，跳出水外，… |
| 围住 | wéi zhù / to surround; to crowd around | ok | ”众猴把他围住，问道：“里面怎么样？ |
| 问道 | wèn dào / asked, saying (introduces direct speech) | ok | ”众猴把他围住，问道：“里面怎么样？ |
| 没 | méi / no; there is/was none | ok | ”石猴道：“没水！ |
| 天造地设 | tiān zào dì shè / perfect, as if made by heaven itself | ok | 原来是一座铁板桥，桥那边是一座天造地设的家当。 |
| 家当 | jiā dàng / home; estate; household property | ok | 原来是一座铁板桥，桥那边是一座天造地设的家当。 |
| 门户 | mén hù / doorway; entrance | ok | ”石猴笑道：“这股水乃是桥下冲贯石桥，倒挂下来遮闭门… |
| 老小 | lǎo xiǎo / young and old; family members of every age | ok | 里面且是宽阔，容得千百口老小。 |
| 省得 | shěng de / so as to avoid; so as to save (trouble) | ok | 我们都进去住，也省得受老天之气。 |
| 刮风 | guā fēng / to be windy; when the wind blows | ok | 刮风有处躲，下雨好存身。 |
| 霜雪 | shuāng xuě / frost and snow | ok | 霜雪全无惧，雷声永不闻。 |
| 雷声 | léi shēng / thunder | ok | 霜雪全无惧，雷声永不闻。 |
| 永不 | yǒng bù / never | ok | 霜雪全无惧，雷声永不闻。 |
| 祥瑞 | xiáng ruì / auspicious sign; good omen | ok | 烟霞常照耀，祥瑞每蒸熏。 |
| 日日 | rì rì / every day, day after day | ok | 松竹年年秀，奇花日日新。 |
| 个个 | gè gè / each one, one by one | ok | 众猴听得，个个欢喜。 |
| 欢喜 | huān xǐ / happy, delighted | ok | 众猴听得，个个欢喜。 |
| 胆大 | dǎn dà / bold, daring | ok | ”那些猴有胆大的，都跳进去了； |
| 抓耳挠腮 | zhuā ěr náo sāi / to fidget anxiously (idiom, lit. scratch ears and cheeks) | ok | 胆小的，一个个伸头缩颈，抓耳挠腮，大声叫喊，缠一会，… |
| 大声 | dà shēng / loudly, in a loud voice | ok | 胆小的，一个个伸头缩颈，抓耳挠腮，大声叫喊，缠一会，… |
| 叫喊 | jiào hǎn / to shout, yell | ok | 胆小的，一个个伸头缩颈，抓耳挠腮，大声叫喊，缠一会，… |
| 跳过 | tiào guò / to jump over, leap across | ok | 跳过桥头，一个个抢盆夺碗，占灶争床，搬过来，移过去，… |
| 顽劣 | wán liè / unruly, mischievous | ok | 跳过桥头，一个个抢盆夺碗，占灶争床，搬过来，移过去，… |
| 端坐 | duān zuò / to sit upright, sit solemnly | ok | 石猿端坐上面道：“列位呵，‘人而无信，不知其可。 |
| 列位 | liè wèi / everyone present, all of you | ok | 石猿端坐上面道：“列位呵，‘人而无信，不知其可。 |
| 安眠 | ān mián / to sleep peacefully | ok | 我如今进来又出去，出去又进来，寻了这一个洞天与列位安… |
| 何不 | hé bù / why not | ok | 我如今进来又出去，出去又进来，寻了这一个洞天与列位安… |
| 排班 | pái bān / to line up in order (by rank/age) | ok | ”众猴听说，即拱伏无违，一个个序齿排班，朝上礼拜，都… |
| 礼拜 | lǐ bài / to bow in worship, pay homage | ok | ”众猴听说，即拱伏无违，一个个序齿排班，朝上礼拜，都… |
| 大王 | dà wáng / king, great king | ok | ”众猴听说，即拱伏无违，一个个序齿排班，朝上礼拜，都… |
| 自此 | zì cǐ / from then on, thereafter | ok | 自此，石猿高登王位，将“石”字儿隐了，遂称“美猴王”… |
| 王位 | wáng wèi / kingship, the throne | ok | 自此，石猿高登王位，将“石”字儿隐了，遂称“美猴王”… |
| 隐 | yǐn / to hide, conceal | ok | 自此，石猿高登王位，将“石”字儿隐了，遂称“美猴王”… |
| 胞 | bāo / womb; to enclose/gestate as if in a womb | fix|word|bāo|womb; placenta | 三阳交泰产群生，仙石胞含日月精。 |
| 日月 | rì yuè / the sun and moon | ok | 三阳交泰产群生，仙石胞含日月精。 |
| 大道 | dà dào / the Great Way (the ultimate Daoist truth/path) | ok | 借卵化猴完大道，假他名姓配丹成。 |
| 内观 | nèi guān / to look inward; introspection | ok | 内观不识因无相，外合明知作有形。 |
| 明知 | míng zhī / to know clearly; be fully aware | ok | 内观不识因无相，外合明知作有形。 |
| 作 | zuò / to become; to take form as | ok | 内观不识因无相，外合明知作有形。 |
| 有形 | yǒu xíng / having physical form; tangible | ok | 内观不识因无相，外合明知作有形。 |
| 人人 | rén rén / everyone; every person | ok | 历代人人皆属此，称王称圣任纵横。 |
| 猿猴 | yuán hóu / apes and monkeys | ok | 美猴王领一群猿猴、猕猴、马猴等，分派了君臣佐使。 |
| 猕猴 | mí hóu / macaque | ok | 美猴王领一群猿猴、猕猴、马猴等，分派了君臣佐使。 |
| 分派 | fēn pài / to assign; to allot (tasks/roles) | ok | 美猴王领一群猿猴、猕猴、马猴等，分派了君臣佐使。 |
| 飞鸟 | fēi niǎo / birds | ok | 朝游花果山，暮宿水帘洞，合契同情，不入飞鸟之丛，不从… |
| 走兽 | zǒu shòu / beasts; four-footed animals | ok | 朝游花果山，暮宿水帘洞，合契同情，不入飞鸟之丛，不从… |
| 之类 | zhī lèi / and the like; such things | ok | 朝游花果山，暮宿水帘洞，合契同情，不入飞鸟之丛，不从… |
| 不胜 | bù shèng / extremely; unable to bear (an intense feeling) | ok | 朝游花果山，暮宿水帘洞，合契同情，不入飞鸟之丛，不从… |
| 是以 | shì yǐ / therefore; thus | ok | 是以： |
| 秋收 | qiū shōu / autumn harvest | ok | 秋收芋栗延时节，冬觅黄精度岁华。 |
| 芋 | yù / taro | ok | 秋收芋栗延时节，冬觅黄精度岁华。 |
| 享乐 | xiǎng lè / to enjoy oneself; to indulge in pleasure | ok | 美猴王享乐天真，何期有三五百载。 |
| 载 | zǎi / year (as a unit of time) | ok | 美猴王享乐天真，何期有三五百载。 |
| 喜宴 | xǐ yàn / a festive banquet; joyful celebration feast | ok | 一日，与群猴喜宴之间，忽然忧恼，堕下泪来。 |
| 堕 | duò / to fall (as tears falling) | ok | 一日，与群猴喜宴之间，忽然忧恼，堕下泪来。 |
| 罗拜 | luó bài / to bow together in homage; to kneel in respect as a group | ok | 众猴慌忙罗拜道：“大王何为烦恼？ |
| 何为 | hé wèi / why (rhetorical, classical) | ok | 众猴慌忙罗拜道：“大王何为烦恼？ |
| 远虑 | yuǎn lǜ / a worry about the distant future; long-term concern | ok | ”猴王道：“我虽在欢喜之时，却有一点儿远虑，故此烦恼… |
| 故此 | gù cǐ / therefore; for this reason | ok | ”猴王道：“我虽在欢喜之时，却有一点儿远虑，故此烦恼… |
| 仙山 | xiān shān / a mountain inhabited by immortals; a mystical paradise mountain | ok | 我等日日欢会，在仙山福地，古洞神洲，不伏麒麟辖，不伏… |
| 辖 | xiá / to govern; to hold authority over | ok | 我等日日欢会，在仙山福地，古洞神洲，不伏麒麟辖，不伏… |
| 自由自在 | zì yóu zì zài / free and unrestrained; carefree, answering to no one | ok | 我等日日欢会，在仙山福地，古洞神洲，不伏麒麟辖，不伏… |
| 无量 | wú liàng / immeasurable; boundless | ok | 我等日日欢会，在仙山福地，古洞神洲，不伏麒麟辖，不伏… |
| 禽兽 | qín shòu / birds and beasts; animals (as a class of creatures) | ok | ”猴王道：“今日虽不归人王法律，不惧禽兽威严，将来年… |
| 威严 | wēi yán / authority; awe-inspiring power | ok | ”猴王道：“今日虽不归人王法律，不惧禽兽威严，将来年… |
| 年老 | nián lǎo / old in age; aged | ok | ”猴王道：“今日虽不归人王法律，不惧禽兽威严，将来年… |
| 老子 | lǎo zi / old man; old fellow (familiar/informal term appended to a name or title) | ok | ”猴王道：“今日虽不归人王法律，不惧禽兽威严，将来年… |
| 身亡 | shēn wáng / to die; to pass away | ok | ”猴王道：“今日虽不归人王法律，不惧禽兽威严，将来年… |
| 可不 | kě bu / wouldn't it be that... (rhetorical, for emphasis) | ok | ”猴王道：“今日虽不归人王法律，不惧禽兽威严，将来年… |
| 之内 | zhī nèi / within; inside (a given scope or category) | ok | ”猴王道：“今日虽不归人王法律，不惧禽兽威严，将来年… |
| 悲啼 | bēi tí / to wail with grief; to cry out in sorrow | ok | ”众猴闻此言，一个个掩面悲啼，俱以无常为虑。 |
| 无常 | wú cháng / death; the impermanence of life | ok | ”众猴闻此言，一个个掩面悲啼，俱以无常为虑。 |
| 忽 | hū / suddenly | ok | 只见那班部中，忽跳出一个通背猿猴，厉声高叫道：“大王… |
| 厉声 | lì shēng / in a sharp, forceful voice | ok | 只见那班部中，忽跳出一个通背猿猴，厉声高叫道：“大王… |
| 这般 | zhè bān / like this; in this way | ok | 只见那班部中，忽跳出一个通背猿猴，厉声高叫道：“大王… |
| 虫 | chóng / creature (as in the five classes of creatures) | ok | 如今五虫之内，惟有三等名色不伏阎王老子所管。 |
| 惟有 | wéi yǒu / only; the only ones | ok | 如今五虫之内，惟有三等名色不伏阎王老子所管。 |
| 知 | zhī / to know | ok | ”猴王道：“你知那三等人？ |
| 仙 | xiān / immortal (Daoist transcendent being) | ok | ”猿猴道：“乃是佛与仙与神圣三者，躲过轮回，不生不灭… |
| 轮回 | lún huí / cycle of rebirth; samsara | ok | ”猿猴道：“乃是佛与仙与神圣三者，躲过轮回，不生不灭… |
| 何所 | hé suǒ / where; what place | ok | ”猴王道：“此三者居于何所？ |
| 明日 | míng rì / tomorrow | ok | ”猴王闻之，满心欢喜道：“我明日就辞汝等下山，云游海… |
| 下山 | xià shān / to go down the mountain | ok | ”猴王闻之，满心欢喜道：“我明日就辞汝等下山，云游海… |
| 云游 | yún yóu / to wander from place to place (like an itinerant monk) | ok | ”猴王闻之，满心欢喜道：“我明日就辞汝等下山，云游海… |
| 海角 | hǎi jiǎo / corner of the sea; distant shore | ok | ”猴王闻之，满心欢喜道：“我明日就辞汝等下山，云游海… |
| 远涉 | yuǎn shè / to travel far across | ok | ”猴王闻之，满心欢喜道：“我明日就辞汝等下山，云游海… |
| 天涯 | tiān yá / the ends of the earth; a faraway place | ok | ”猴王闻之，满心欢喜道：“我明日就辞汝等下山，云游海… |
| 长生 | cháng shēng / long life; immortality | ok | ”猴王闻之，满心欢喜道：“我明日就辞汝等下山，云游海… |
| 噫 | yī / Ah! (interjection) | ok | ”噫！ |
| 话 | huà / words; a saying | ok | 这句话，顿教跳出轮回网，致使齐天大圣成。 |
| 善哉 | shàn zāi / Excellent! — an exclamation of praise or approval | ok | 众猴鼓掌称扬，都道：“善哉，善哉！ |
| 登山 | dēng shān / to climb a mountain | ok | 我等明日越岭登山，广寻些果品，大设筵宴送大王也。 |
| 果品 | guǒ pǐn / fruit (as food/produce) | ok | 我等明日越岭登山，广寻些果品，大设筵宴送大王也。 |
| 筵宴 | yán yàn / a feast; banquet | ok | 我等明日越岭登山，广寻些果品，大设筵宴送大王也。 |
| 山药 | shān yao / yam (edible root) | ok | 次日，众猴果去采仙桃，摘异果，刨山药，斸黄精。 |
| 斸 | zhǔ / to dig up or hack at (with a hoe) | ok | 次日，众猴果去采仙桃，摘异果，刨山药，斸黄精。 |
| 黄精 | huáng jīng / Solomon's seal (a medicinal root plant) | ok | 次日，众猴果去采仙桃，摘异果，刨山药，斸黄精。 |
| 般 | bān / kind; sort (as in "all sorts of things") | ok | 芝兰香蕙，瑶草奇花，般般件件，整整齐齐，摆开石凳石桌… |
| 整整齐齐 | zhěng zhěng qí qí / neat and orderly | ok | 芝兰香蕙，瑶草奇花，般般件件，整整齐齐，摆开石凳石桌… |
| 肴 | yáo / meat dishes; delicacies | ok | 芝兰香蕙，瑶草奇花，般般件件，整整齐齐，摆开石凳石桌… |
| 樱桃 | yīng táo / cherry | ok | 金丸珠弹腊樱桃，色真甘美； |
| 梅子 | méi zi / plum | ok | 红绽黄肥熟梅子，味果香酸。 |
| 龙眼 | lóng yǎn / longan (dragon-eye fruit) | ok | 鲜龙眼，肉甜皮薄； |
| 荔枝 | lì zhī / lychee | ok | 火荔枝，核小囊红。 |
| 林檎 | lín qín / Chinese pearleaf crabapple | ok | 林檎碧实连枝献，枇杷缃苞带叶擎。 |
| 枇杷 | pí pa / loquat | ok | 林檎碧实连枝献，枇杷缃苞带叶擎。 |
| 缃 | xiāng / light yellow (color) | ok | 林檎碧实连枝献，枇杷缃苞带叶擎。 |
| 苞 | bāo / bud; calyx (the covering around a fruit cluster) | ok | 林檎碧实连枝献，枇杷缃苞带叶擎。 |
| 梨子 | lí zi / pear | ok | 兔头梨子鸡心枣，消渴除烦更解酲。 |
| 消渴 | xiāo kě / a wasting thirst disorder (TCM term, diabetes-like) | fix|word|xiāo kě|to quench thirst | 兔头梨子鸡心枣，消渴除烦更解酲。 |
| 酲 | chéng / hungover; the lingering after-effects of drinking | fix|word|chéng|hangover; the after-effects of drinking | 兔头梨子鸡心枣，消渴除烦更解酲。 |
| 荫 | yīn / cool and shady — used here to describe a refreshing, faintly tart coolness | fix|word|yīn|shady; cool and shaded | 脆李杨梅，酸荫荫如脂酥膏酪。 |
| 黑子 | hēizǐ / black seeds (of a fruit, here watermelon) | ok | 红囊黑子熟西瓜，四瓣黄皮大柿子。 |
| 瓣 | bàn / a segment or slice (of a fruit) | ok | 红囊黑子熟西瓜，四瓣黄皮大柿子。 |
| 石榴 | shíliu / pomegranate | ok | 石榴裂破，丹砂粒现火晶珠； |
| 玛瑙 | mǎnǎo / agate — a banded reddish stone, used to describe the fruit's gem-like flesh | fix|word|mǎnǎo|agate, a banded semiprecious stone | 芋栗剖开，坚硬肉团金玛瑙。 |
| 胡桃 | hútáo / walnut | ok | 胡桃银杏可传茶，椰子葡萄能做酒。 |
| 银杏 | yínxìng / ginkgo nut | ok | 胡桃银杏可传茶，椰子葡萄能做酒。 |
| 榧 | fěi / torreya nut — an edible pine-like nut | ok | 榛松榧奈满盘盛，橘蔗柑橙盈案摆。 |
| 满盘 | mǎnpán / filling the whole plate/tray | ok | 榛松榧奈满盘盛，橘蔗柑橙盈案摆。 |
| 煨 | wēi / to simmer slowly, as in hot ashes or embers | ok | 熟煨山药，烂煮黄精。 |
| 捣碎 | dǎosuì / to pound into pieces; to mash | ok | 捣碎茯苓并薏苡，石锅微火漫炊羹。 |
| 茯苓 | fúlíng / tuckahoe — a medicinal fungus used in Chinese cooking | ok | 捣碎茯苓并薏苡，石锅微火漫炊羹。 |
| 薏苡 | yìyǐ / Job's tears — a barley-like grain used in soups | ok | 捣碎茯苓并薏苡，石锅微火漫炊羹。 |
| 微火 | wēihuǒ / a low, gentle fire | ok | 捣碎茯苓并薏苡，石锅微火漫炊羹。 |
| 羹 | gēng / a thick soup or stew | ok | 捣碎茯苓并薏苡，石锅微火漫炊羹。 |
| 珍馐 | zhēnxiū / rare delicacies; exquisite food | ok | 人间纵有珍馐味，怎比山猴乐更宁。 |
| 肩 | jiān / shoulder; here (in "依齿肩") extended to mean rank/seniority order | fix|word|jiān|shoulder; (here) seniority rank in seating order | 群猴尊美猴王上坐，各依齿肩排于下边，一个个轮流上前奉… |
| 下边 | xià bian / below; the lower/inferior position (where the junior monkeys sit) | ok | 群猴尊美猴王上坐，各依齿肩排于下边，一个个轮流上前奉… |
| 上前 | shàng qián / to step forward | ok | 群猴尊美猴王上坐，各依齿肩排于下边，一个个轮流上前奉… |
| 奉 | fèng / to offer respectfully (presenting wine, flowers, fruit) | ok | 群猴尊美猴王上坐，各依齿肩排于下边，一个个轮流上前奉… |
| 果 | guǒ / fruit | ok | 群猴尊美猴王上坐，各依齿肩排于下边，一个个轮流上前奉… |
| 痛饮 | tòng yǐn / to drink one's fill; to drink heartily | ok | 群猴尊美猴王上坐，各依齿肩排于下边，一个个轮流上前奉… |
| 早起 | zǎo qǐ / to get up early | ok | 次日，美猴王早起，教：“小的们，替我折些枯松，编作筏… |
| 筏子 | fá zi / raft | ok | 次日，美猴王早起，教：“小的们，替我折些枯松，编作筏… |
| 撑开 | chēng kāi / to push off with a pole; to propel (a raft) with full force | ok | ”果独自登筏，尽力撑开，飘飘荡荡，径向大海波中，趁天… |
| 波 | bō / wave | ok | ”果独自登筏，尽力撑开，飘飘荡荡，径向大海波中，趁天… |
| 道行 | dào héng / spiritual attainment; level of skill from religious/Daoist cultivation | ok | 天产仙猴道行隆，离山驾筏趁天风。 |
| 隆 | lóng / grand; profound (describing the depth of his cultivation) | ok | 天产仙猴道行隆，离山驾筏趁天风。 |
| 立志 | lì zhì / to set one's resolve; to become determined | ok | 飘洋过海寻仙道，立志潜心建大功。 |
| 大功 | dà gōng / great achievement; great merit | ok | 飘洋过海寻仙道，立志潜心建大功。 |
| 说破 | shuō pò / to reveal; to lay bare (a secret) | ok | 料应必遇知音者，说破源流万法通。 |
| 木筏 | mù fá / wooden raft | ok | 也是他运至时来，自登木筏之后，连日东南风紧，将他送到… |
| 连日 | lián rì / day after day; for several days running | ok | 也是他运至时来，自登木筏之后，连日东南风紧，将他送到… |
| 试水 | shì shuǐ / to test the water's depth (with a pole) | ok | 持篙试水，偶得浅水，弃了筏子，跳上岸来。 |
| 浅水 | qiǎn shuǐ / shallow water | ok | 持篙试水，偶得浅水，弃了筏子，跳上岸来。 |
| 弃 | qì / to abandon, leave behind | ok | 持篙试水，偶得浅水，弃了筏子，跳上岸来。 |
| 上岸 | shàng àn / to go ashore, climb onto the shore | ok | 持篙试水，偶得浅水，弃了筏子，跳上岸来。 |
| 海边 | hǎi biān / seaside, coast | ok | 只见海边有人捕鱼、打雁、穵蛤、淘盐。 |
| 有人 | yǒu rén / there were people, some people | ok | 只见海边有人捕鱼、打雁、穵蛤、淘盐。 |
| 捕鱼 | bǔ yú / to catch fish, fish | ok | 只见海边有人捕鱼、打雁、穵蛤、淘盐。 |
| 雁 | yàn / wild goose | ok | 只见海边有人捕鱼、打雁、穵蛤、淘盐。 |
| 穵 | wā / to dig, scoop out | ok | 只见海边有人捕鱼、打雁、穵蛤、淘盐。 |
| 蛤 | gé / clam | ok | 只见海边有人捕鱼、打雁、穵蛤、淘盐。 |
| 走近 | zǒu jìn / to approach, go up close | ok | 他走近前，弄个把戏，妆个𡤫虎，吓得那些人丢筐弃网，四… |
| 把戏 | bǎ xì / a trick, a stunt | ok | 他走近前，弄个把戏，妆个𡤫虎，吓得那些人丢筐弃网，四… |
| 妆 | zhuāng / to dress up as, disguise oneself as | ok | 他走近前，弄个把戏，妆个𡤫虎，吓得那些人丢筐弃网，四… |
| 虎 | hǔ / tiger | ok | 他走近前，弄个把戏，妆个𡤫虎，吓得那些人丢筐弃网，四… |
| 四散 | sì sàn / to scatter in all directions | ok | 他走近前，弄个把戏，妆个𡤫虎，吓得那些人丢筐弃网，四… |
| 身上 | shēn shang / on the body | ok | 将那跑不动的拿住一个，剥了他的衣裳，也学人穿在身上。 |
| 摇摇摆摆 | yáo yáo bǎi bǎi / swaggering, strutting | ok | 摇摇摆摆，穿州过府，在市廛中学人礼，学人话。 |
| 觅 | mì / to seek, look for | ok | 朝餐夜宿，一心里访问佛、仙、神圣之道，觅个长生不老之… |
| 长生不老 | cháng shēng bù lǎo / immortality, eternal youth | ok | 朝餐夜宿，一心里访问佛、仙、神圣之道，觅个长生不老之… |
| 争名夺利 | zhēng míng duó lì / to scramble for fame and wealth; chasing status and profit | ok | 争名夺利几时休？ |
| 驴骡 | lǘ luó / a hinny/mule-type pack animal (donkey-horse cross) | fix|word|lǘ luó|donkeys and mules; humble pack mounts | 骑著驴骡思骏马，官居宰相望王侯。 |
| 思 | sī / to long for; to yearn for | ok | 骑著驴骡思骏马，官居宰相望王侯。 |
| 宰相 | zǎi xiàng / prime minister (in imperial China) | ok | 骑著驴骡思骏马，官居宰相望王侯。 |
| 王侯 | wáng hóu / the nobility; lords and princes | ok | 骑著驴骡思骏马，官居宰相望王侯。 |
| 衣食 | yī shí / food and clothing; basic livelihood | ok | 只愁衣食耽劳碌，何怕阎君就取勾。 |
| 耽 | dān / to be absorbed in; to indulge in | ok | 只愁衣食耽劳碌，何怕阎君就取勾。 |
| 劳碌 | láo lù / toil; hard work | ok | 只愁衣食耽劳碌，何怕阎君就取勾。 |
| 继子 | jì zǐ / stepson | fix|artifact|jì zǐ|Mis-segmentation: the line reads 继子/荫孙 (verb+object pairs) — 继 "pass on wealth to" + 子 "sons", parallel to 荫孙 "shelter grandsons". Not the word 继子 "stepson". | 继子荫孙图富贵，更无一个肯回头。 |
| 富贵 | fù guì / wealth and high status | ok | 继子荫孙图富贵，更无一个肯回头。 |
| 不觉 | bù jué / without realizing; before one knows it | ok | 在于南赡部洲，串长城，游小县，不觉八九年馀。 |
| 登岸 | dēng àn / to go ashore; to land | ok | 登岸遍访多时，忽见一座高山秀丽，林麓幽深。 |
| 多时 | duō shí / a long time | ok | 登岸遍访多时，忽见一座高山秀丽，林麓幽深。 |
| 高山 | gāo shān / a tall, high mountain | ok | 登岸遍访多时，忽见一座高山秀丽，林麓幽深。 |
| 幽深 | yōu shēn / deep and secluded; tranquil | ok | 登岸遍访多时，忽见一座高山秀丽，林麓幽深。 |
| 不怕 | bù pà / not afraid, unbothered by (danger or hardship) | ok | 他也不怕狼虫，不惧虎豹，登在山顶上观看。 |
| 峰 | fēng / mountain peak, summit | ok | 千峰排戟，万仞开屏。 |
| 仞 | rèn / ancient unit of length (~7-8 Chinese feet), used to measure height/depth | ok | 千峰排戟，万仞开屏。 |
| 开屏 | kāi píng / to fan out, spread open (like a peacock's tail or folding screen) — here describing peaks unfurling in a row | fix|word|kāi píng|to spread open like a screen | 千峰排戟，万仞开屏。 |
| 奇 | qí / rare, wondrous, extraordinary | ok | 奇花瑞草，修竹乔松。 |
| 万载 | wàn zǎi / ten thousand years, an age (poetic term for a very long time) | ok | 修竹乔松，万载常青欺福地； |
| 常青 | cháng qīng / evergreen, always green | ok | 修竹乔松，万载常青欺福地； |
| 欺 | qī / to surpass, outshine, rival (classical usage; not "deceive" here) | fix|word|qī|to surpass, outshine | 修竹乔松，万载常青欺福地； |
| 四时 | sì shí / the four seasons | ok | 奇花瑞草，四时不谢赛蓬瀛。 |
| 幽 | yōu / secluded, hidden away, remote (describing a bird's call from a hidden spot) | fix|word|yōu|secluded, hidden, remote | 幽鸟啼声近，源泉响溜清。 |
| 巉 | chán / steep, jagged, precipitous | ok | 重重谷壑芝兰绕，处处巉崖苔藓生。 |
| 崖 | yá / cliff, precipice | ok | 重重谷壑芝兰绕，处处巉崖苔藓生。 |
| 苔藓 | tái xiǎn / moss | ok | 重重谷壑芝兰绕，处处巉崖苔藓生。 |
| 峦 | luán / mountain peak/ridge (part of 峦头, a fengshui term for landform) | ok | 起伏峦头龙脉好，必有高人隐姓名。 |
| 龙脉 | lóng mài / "dragon vein" — a mountain ridge formation seen as auspicious in feng shui | ok | 起伏峦头龙脉好，必有高人隐姓名。 |
| 忽闻 | hū wén / to suddenly hear | ok | 正观看间，忽闻得林深之处有人言语。 |
| 侧耳 | cè ěr / to listen closely, incline one's ear | ok | 急忙趋步，穿入林中，侧耳而听，原来是歌唱之声。 |
| 伐木 | fá mù / to fell trees, chop wood | ok | “观棋柯烂，伐木丁丁，云边谷口徐行。 |
| 丁丁 | zhēng zhēng / onomatopoeia for the sound of an axe chopping wood | ok | “观棋柯烂，伐木丁丁，云边谷口徐行。 |
| 谷口 | gǔ kǒu / the mouth/entrance of a valley | ok | “观棋柯烂，伐木丁丁，云边谷口徐行。 |
| 徐行 | xú xíng / to walk slowly, stroll | ok | “观棋柯烂，伐木丁丁，云边谷口徐行。 |
| 狂笑 | kuáng xiào / to laugh loudly, roar with laughter | ok | 卖薪沽酒，狂笑自陶情。 |
| 苍 | cāng / dark blue-green, grey (describing scenery) | ok | 苍迳秋高对月，枕松根、一觉天明。 |
| 迳 | jìng / a path, trail | ok | 苍迳秋高对月，枕松根、一觉天明。 |
| 秋 | qiū / autumn | ok | 苍迳秋高对月，枕松根、一觉天明。 |
| 觉 | jiào / a sleep, a nap | ok | 苍迳秋高对月，枕松根、一觉天明。 |
| 天明 | tiān míng / dawn, daybreak | ok | 苍迳秋高对月，枕松根、一觉天明。 |
| 林 | lín / forest, woods | ok | 认旧林，登崖过岭，持斧断枯藤。 |
| 时价 | shí jià / current price, going rate | ok | 更无些子争竞，时价平平。 |
| 平平 | píng píng / average, ordinary, so-so | ok | 更无些子争竞，时价平平。 |
| 不会 | bù huì / not knowing how to, not skilled at | ok | 不会机谋巧算，没荣辱、恬淡延生。 |
| 机谋 | jī móu / stratagem, scheming | ok | 不会机谋巧算，没荣辱、恬淡延生。 |
| 荣辱 | róng rǔ / honor and disgrace | ok | 不会机谋巧算，没荣辱、恬淡延生。 |
| 恬淡 | tián dàn / content and indifferent to fame or gain | ok | 不会机谋巧算，没荣辱、恬淡延生。 |
| 相逢 | xiāng féng / to meet by chance, cross paths | ok | 相逢处，非仙即道，静坐讲《黄庭》。 |
| 静坐 | jìng zuò / to sit quietly, meditate | ok | 相逢处，非仙即道，静坐讲《黄庭》。 |
| 樵子 | qiáo zǐ / woodcutter | ok | ”即忙跳入里面，仔细再看，乃是一个樵子，在那里举斧砍… |
| 头上 | tóu shàng / on top of the head, overhead | ok | 头上戴箬笠，乃是新笋初脱之箨。 |
| 箨 | tuò / sheath shed by a growing bamboo shoot | ok | 头上戴箬笠，乃是新笋初脱之箨。 |
| 布衣 | bù yī / plain cloth clothing, homespun garments | ok | 身上穿布衣，乃是木绵撚就之纱。 |
| 撚 | niǎn / twisted (thread spun by twisting with the fingers) | fix|word|niǎn|to twist fibers into thread | 身上穿布衣，乃是木绵撚就之纱。 |
| 腰间 | yāo jiān / around the waist | ok | 腰间系环绦，乃是老蚕口吐之丝。 |
| 绦 | tāo / braided cord, sash | ok | 腰间系环绦，乃是老蚕口吐之丝。 |
| 足下 | zú xià / on one's feet, beneath the feet | ok | 足下踏草履，乃是枯莎槎就之爽。 |
| 槎 | chá / hewn/twisted together, fashioned by hand | fix|word|chá|to hew and plait together | 足下踏草履，乃是枯莎槎就之爽。 |
| 枯树 | kū shù / dead, withered tree | ok | 扳松劈枯树，争似此樵能。 |
| 樵 | qiáo / woodcutter (elliptical for 樵夫) | ok | 扳松劈枯树，争似此樵能。 |
| 近前 | jìn qián / to step closer, approach | ok | 猴王近前叫道：“老神仙，弟子起手。 |
| 起手 | qǐ shǒu / a polite greeting, bowing with hands raised | fix|word|qǐ shǒu|to salute by raising clasped hands | 猴王近前叫道：“老神仙，弟子起手。 |
| 汉 | hàn / fellow, man | ok | ”那樵汉慌忙丢了斧，转身答礼道：“不当人，不当人。 |
| 斧 | fǔ / axe, hatchet | ok | ”那樵汉慌忙丢了斧，转身答礼道：“不当人，不当人。 |
| 答礼 | dá lǐ / to return a bow, respond to a greeting | ok | ”那樵汉慌忙丢了斧，转身答礼道：“不当人，不当人。 |
| 怎 | zěn / how | ok | 我拙汉衣食不全，怎敢当‘神仙’二字？ |
| 不是 | bù shì / is not, are not | ok | ”猴王道：“你不是神仙，如何说出神仙的话来？ |
| 说出 | shuō chū / to say, to utter | ok | ”猴王道：“你不是神仙，如何说出神仙的话来？ |
| 樵夫 | qiáo fū / woodcutter | ok | ”樵夫道：“我说甚么神仙话？ |
| 林边 | lín biān / edge of the forest | ok | ”猴王道：“我才来至林边，只听的你说：‘相逢处，非仙… |
| 真言 | zhēn yán / true words, sacred teaching | ok | ’《黄庭》乃道德真言，非神仙而何？ |
| 实 | shí / honestly; truly (used before admitting or confessing something) | ok | ”樵夫笑道：“实不瞒你说，这个词名做《满庭芳》，乃一… |
| 舍下 | shè xià / my humble home (self-deprecating term for one's house) | ok | 那神仙与我舍下相邻，他见我家事劳苦，日常烦恼，教我遇… |
| 相邻 | xiāng lín / neighboring; next door to | ok | 那神仙与我舍下相邻，他见我家事劳苦，日常烦恼，教我遇… |
| 家事 | jiā shì / family matters; household affairs | ok | 那神仙与我舍下相邻，他见我家事劳苦，日常烦恼，教我遇… |
| 劳苦 | láo kǔ / toil and hardship; hard labor | fix|word|láo kǔ|toilsome; wearisome; to toil hard | 那神仙与我舍下相邻，他见我家事劳苦，日常烦恼，教我遇… |
| 遇 | yù / to encounter; to meet with (something, e.g. troubles) | ok | 那神仙与我舍下相邻，他见我家事劳苦，日常烦恼，教我遇… |
| 一则 | yī zé / for one thing; on the one hand | ok | 那神仙与我舍下相邻，他见我家事劳苦，日常烦恼，教我遇… |
| 散心 | sàn xīn / to unwind; to take one's mind off troubles | ok | 那神仙与我舍下相邻，他见我家事劳苦，日常烦恼，教我遇… |
| 思虑 | sī lǜ / worries; troubled thoughts | ok | 我才有些不足处思虑，故此念念，不期被你听了。 |
| 不期 | bù qī / unexpectedly; not expecting that | ok | 我才有些不足处思虑，故此念念，不期被你听了。 |
| 修行 | xiū xíng / to practice self-cultivation (Daoist/Buddhist spiritual training) | ok | ”猴王道：“你家既与神仙相邻，何不从他修行？ |
| 命苦 | mìng kǔ / to have a hard lot in life; born unlucky | ok | ”樵夫道：“我一生命苦：自幼蒙父母养育至八九岁，才知… |
| 自幼 | zì yòu / since childhood | ok | ”樵夫道：“我一生命苦：自幼蒙父母养育至八九岁，才知… |
| 父丧 | fù sāng / the death of one's father | ok | ”樵夫道：“我一生命苦：自幼蒙父母养育至八九岁，才知… |
| 居孀 | jū shuāng / to live on as a widow | ok | ”樵夫道：“我一生命苦：自幼蒙父母养育至八九岁，才知… |
| 姊妹 | zǐ mèi / sisters | ok | 再无兄弟姊妹，只我一人，没奈何，早晚侍奉。 |
| 没奈何 | mò nài hé / to have no choice; helplessly | ok | 再无兄弟姊妹，只我一人，没奈何，早晚侍奉。 |
| 侍奉 | shì fèng / to wait on and care for (a parent) | ok | 再无兄弟姊妹，只我一人，没奈何，早晚侍奉。 |
| 一发 | yī fā / all the more; even more so (classical usage; the CEDICT mahjong sense doesn't apply here) | fix|word|yī fā|all the more; even more so (classical) | 如今母老，一发不敢抛离。 |
| 抛离 | pāo lí / to abandon; to leave behind | ok | 如今母老，一发不敢抛离。 |
| 荒芜 | huāng wú / overgrown; fallen into disuse (of fields/land) | ok | 却又田园荒芜，衣食不足，只得斫两束柴薪，挑向市廛之间… |
| 斫 | zhuó / to chop (wood) | ok | 却又田园荒芜，衣食不足，只得斫两束柴薪，挑向市廛之间… |
| 柴薪 | chái xīn / firewood | ok | 却又田园荒芜，衣食不足，只得斫两束柴薪，挑向市廛之间… |
| 籴 | dí / to buy (grain/rice) | ok | 却又田园荒芜，衣食不足，只得斫两束柴薪，挑向市廛之间… |
| 老母 | lǎo mǔ / one's aged/elderly mother | ok | 却又田园荒芜，衣食不足，只得斫两束柴薪，挑向市廛之间… |
| 不能 | bù néng / cannot; unable to | ok | 所以不能修行。 |
| 叫做 | jiào zuò / to be called; to be named | ok | 此山叫做灵台方寸山，山中有座斜月三星洞，那洞中有一个… |
| 方寸 | fāng cùn / the heart; the mind (lit. "a square inch," the seat of thought) | ok | 此山叫做灵台方寸山，山中有座斜月三星洞，那洞中有一个… |
| 三星 | sān xīng / three stars (an asterism), used here in a cave's name as a pun on the character for "heart" | fix|word|sān xīng|three stars | 此山叫做灵台方寸山，山中有座斜月三星洞，那洞中有一个… |
| 祖师 | zǔ shī / founder; patriarch (title for the master of a school or sect) | ok | 此山叫做灵台方寸山，山中有座斜月三星洞，那洞中有一个… |
| 不计其数 | bù jì qí shù / countless; too many to count | ok | 那祖师出去的徒弟，也不计其数，见今还有三四十人从他修… |
| 今 | jīn / now; at present | ok | 那祖师出去的徒弟，也不计其数，见今还有三四十人从他修… |
| 还有 | hái yǒu / there are still; there remain | ok | 那祖师出去的徒弟，也不计其数，见今还有三四十人从他修… |
| 小路 | xiǎo lù / path; trail; small road | ok | 你顺那条小路儿，向南行七八里远近，即是他家了。 |
| 儿 | r / diminutive suffix attached to a noun, giving it a casual tone | ok | 你顺那条小路儿，向南行七八里远近，即是他家了。 |
| 远近 | yuǎn jìn / roughly; more or less (of a distance) — lit. "far or near" | ok | 你顺那条小路儿，向南行七八里远近，即是他家了。 |
| 扯住 | chě zhù / to grab hold of; to seize | ok | ”猴王用手扯住樵夫道：“老兄，你便同我去去，若还得了… |
| 老兄 | lǎo xiōng / old chap; buddy (form of address between male friends) | ok | ”猴王用手扯住樵夫道：“老兄，你便同我去去，若还得了… |
| 决不 | jué bù / absolutely not; never | ok | ”猴王用手扯住樵夫道：“老兄，你便同我去去，若还得了… |
| 汉子 | hànzi / fellow; guy (way of addressing a man) | ok | ”樵夫道：“你这汉子甚不通变，我方才这般与你说了，你… |
| 甚 | shèn / very; extremely | ok | ”樵夫道：“你这汉子甚不通变，我方才这般与你说了，你… |
| 方才 | fāngcái / just now; a moment ago | ok | ”樵夫道：“你这汉子甚不通变，我方才这般与你说了，你… |
| 假若 | jiǎruò / if; supposing | ok | 假若我与你去了，却不误了我的生意？ |
| 何人 | hérén / who (lit. "what person") | ok | 老母何人奉养？ |
| 奉养 | fèngyǎng / to support and care for (one's aging parents) | ok | 老母何人奉养？ |
| 柴 | chái / firewood | ok | 我要斫柴，你自去，自去。 |
| 望见 | wàngjiàn / to catch sight of; spot from a distance | ok | 出深林，找上路径，过一山坡，约有七八里远，果然望见一… |
| 洞府 | dòngfǔ / cave dwelling, home of an immortal or spirit | ok | 出深林，找上路径，过一山坡，约有七八里远，果然望见一… |
| 挺身 | tǐngshēn / to straighten up; stand up tall | ok | 挺身观看，真好去处！ |
| 半空 | bànkōng / midair; up in the sky | ok | 千株老柏，带雨半空青冉冉； |
| 冉冉 | rǎnrǎn / drooping softly; swaying gently | ok | 千株老柏，带雨半空青冉冉； |
| 苍苍 | cāngcāng / lush gray-green; hazy blue-green | ok | 万节修篁，含烟一壑色苍苍。 |
| 门外 | ménwài / outside the gate | ok | 门外奇花布锦，桥边瑶草喷香。 |
| 喷香 | pènxiāng / sweetly fragrant | ok | 门外奇花布锦，桥边瑶草喷香。 |
| 青苔 | qīngtái / moss | ok | 石崖突兀青苔润，悬壁高张翠藓长。 |
| 唳 | lì / to cry, call (of a crane) | ok | 时闻仙鹤唳，每见凤凰翔。 |
| 翔 | xiáng / to soar or glide, as a bird in flight | ok | 时闻仙鹤唳，每见凤凰翔。 |
| 皋 | gāo / marsh; riverbank (as in "nine marshes," the crane's traditional cry-place) | ok | 仙鹤唳时，声振九皋霄汉远； |
| 霄汉 | xiāo hàn / the sky; the heavens | ok | 仙鹤唳时，声振九皋霄汉远； |
| 翎毛 | líng máo / feathers; plumage | ok | 凤凰翔起，翎毛五色彩云光。 |
| 紧闭 | jǐn bì / shut tight, firmly closed | ok | 又见那洞门紧闭，静悄悄杳无人迹。 |
| 静悄悄 | jìng qiāo qiāo / dead silent, hushed | ok | 又见那洞门紧闭，静悄悄杳无人迹。 |
| 杳无人迹 | yǎo wú rén jì / not a trace of anyone; utterly deserted | ok | 又见那洞门紧闭，静悄悄杳无人迹。 |
| 石碑 | shí bēi / stone tablet; stele | ok | 忽回头，见崖头立一石碑，约有三丈馀高，八尺馀阔，上有… |
| 阔 | kuò / wide, broad (measuring width) | ok | 忽回头，见崖头立一石碑，约有三丈馀高，八尺馀阔，上有… |
| 此间 | cǐ jiān / this place, here | ok | 美猴王十分欢喜道：“此间人果是朴实，果有此山此洞。 |
| 敲门 | qiāo mén / to knock on a door | ok | ”看够多时，不敢敲门。 |
| 松子 | sōng zǐ / pine nut | ok | 且去跳上松枝梢头，摘松子吃了顽耍。 |
| 少顷 | shǎo qǐng / after a little while, presently | ok | 少顷间，只听得呀的一声，洞门开处，里面走出一个仙童，… |
| 走出 | zǒu chū / to walk out, come outside | ok | 少顷间，只听得呀的一声，洞门开处，里面走出一个仙童，… |
| 仙童 | xiān tóng / a young attendant serving an immortal or deity (temple page boy) | ok | 少顷间，只听得呀的一声，洞门开处，里面走出一个仙童，… |
| 丰姿 | fēng zī / elegant bearing, fine looks | ok | 少顷间，只听得呀的一声，洞门开处，里面走出一个仙童，… |
| 像貌 | xiàng mào / facial features, appearance | ok | 少顷间，只听得呀的一声，洞门开处，里面走出一个仙童，… |
| 绾 | wǎn / to bind up or coil (hair) | ok | 髽髻双丝绾，宽袍两袖风。 |
| 袖 | xiù / sleeve | ok | 髽髻双丝绾，宽袍两袖风。 |
| 貌 | mào / appearance; outward form | ok | 貌和身自别，心与相俱空。 |
| 物 | wù / the material world; worldly things (as opposed to spirit) | ok | 物外长年客，山中永寿童。 |
| 永寿 | yǒng shòu / eternal longevity (literal meaning here, not the place name) | ok | 物外长年客，山中永寿童。 |
| 童 | tóng / child | ok | 物外长年客，山中永寿童。 |
| 尘 | chén / dust; worldly impurity | ok | 一尘全不染，甲子任翻腾。 |
| 翻腾 | fān téng / to churn, roll on (of time's cycles turning) | ok | 一尘全不染，甲子任翻腾。 |
| 童子 | tóng zǐ / boy; young attendant | ok | 那童子出得门来，高叫道：“甚么人在此搔扰？ |
| 搔扰 | sāo rǎo / to disturb, make a racket | ok | 那童子出得门来，高叫道：“甚么人在此搔扰？ |
| 躬身 | gōng shēn / to bow | ok | ”猴王扑的跳下树来，上前躬身道：“仙童，我是个访道学… |
| 访 | fǎng / to seek out, search for | ok | ”猴王扑的跳下树来，上前躬身道：“仙童，我是个访道学… |
| 么 | ma / question particle marking a yes/no question | ok | ”仙童笑道：“你是个访道的么？ |
| 下榻 | xià tà / to get up from one's seat/couch (older literal sense; not the modern "stay at a hotel") | ok | ”童子道：“我家师父正才下榻，登坛讲道，还未说出原由… |
| 讲道 | jiǎng dào / to lecture on the Way, preach | ok | ”童子道：“我家师父正才下榻，登坛讲道，还未说出原由… |
| 原由 | yuán yóu / reason, cause | ok | ”童子道：“我家师父正才下榻，登坛讲道，还未说出原由… |
| 开门 | kāi mén / to open the door | ok | ”童子道：“我家师父正才下榻，登坛讲道，还未说出原由… |
| 想必 | xiǎng bì / presumably, surely | ok | ’想必就是你了？ |
| 深处 | shēn chù / the innermost depths | ok | 这猴王整衣端肃，随童子径入洞天深处观看：一层层深阁琼… |
| 层层 | céng céng / layer upon layer | ok | 这猴王整衣端肃，随童子径入洞天深处观看：一层层深阁琼… |
| 不尽 | bù jìn / unable to fully describe or finish telling | fix|word|bù jìn|endless; inexhaustible (说不尽: cannot finish telling) | 这猴王整衣端肃，随童子径入洞天深处观看：一层层深阁琼… |
| 台上 | tái shàng / on the platform/dais | ok | 直至瑶台之下，见那菩提祖师端坐在台上，两边有三十个小… |
| 两边 | liǎng biān / on both sides | ok | 直至瑶台之下，见那菩提祖师端坐在台上，两边有三十个小… |
| 侍立 | shì lì / to stand in attendance | ok | 直至瑶台之下，见那菩提祖师端坐在台上，两边有三十个小… |
| 台下 | tái xià / below the platform | ok | 直至瑶台之下，见那菩提祖师端坐在台上，两边有三十个小… |
| 慈 | cí / compassion, mercy | ok | 不生不灭三三行，全气全神万万慈。 |
| 空寂 | kōng jì / empty and still (Buddhist term for stillness) | ok | 空寂自然随变化，真如本性任为之。 |
| 真如 | zhēn rú / True Suchness — the ultimate unchanging reality (Buddhist term) | ok | 空寂自然随变化，真如本性任为之。 |
| 体 | tǐ / body, form | ok | 与天同寿庄严体，历劫明心大法师。 |
| 磕头 | kē tóu / to kowtow (bow with forehead to the ground) | ok | 美猴王一见，倒身下拜，磕头不计其数，口中只道：“师父… |
| 人氏 | rén shì / a native, person from a place | ok | ”祖师道：“你是那方人氏？ |
| 且说 | qiě shuō / go ahead and state (introduces what follows) | fix|word|qiě shuō|just state, go ahead and say | 且说个乡贯、姓名明白，再拜。 |
| 乡贯 | xiāng guàn / native place, place of origin | ok | 且说个乡贯、姓名明白，再拜。 |
| 再拜 | zài bài / to bow twice (gesture of respect) | ok | 且说个乡贯、姓名明白，再拜。 |
| 喝令 | hè lìng / to shout an order | ok | ”祖师喝令：“赶出去！ |
| 不住 | bù zhù / nonstop, unable to stop | ok | ”猴王慌忙磕头不住道：“弟子是老实之言，决无虚诈。 |
| 虚诈 | xū zhà / deceitful, dishonest | ok | ”猴王慌忙磕头不住道：“弟子是老实之言，决无虚诈。 |
| 叩头 | kòu tóu / to kowtow (bow with forehead to the ground) | ok | ”猴王叩头道：“弟子飘洋过海，登界游方，有十数个年头… |
| 十数 | shí shù / a dozen or more, more than ten | ok | ”猴王叩头道：“弟子飘洋过海，登界游方，有十数个年头… |
| 年头 | nián tóu / a year (as a stretch of time); here, "over ten years" traveling | ok | ”猴王叩头道：“弟子飘洋过海，登界游方，有十数个年头… |
| 也罢 | yě bà / well then, fine — reluctant acceptance of what was said | ok | 祖师道：“既是逐渐行来的也罢。 |
| 无性 | wú xìng / to have no temper, never get angry (a pun: monkey misheard "surname" as "temper," both pronounced xìng) | ok | ”猴王又道：“我无性。 |
| 嗔 | chēn / to get angry, take offense | ok | 若打我，我也不嗔。 |
| 却是 | què shì / but in fact, actually | ok | ”猴王道：“我虽不是树上生，却是石里长的。 |
| 闻言 | wén yán / upon hearing this, having heard those words | ok | ”祖师闻言暗喜，道：“这等说，却是个天地生成的。 |
| 暗喜 | àn xǐ / secretly pleased, inwardly delighted | ok | ”祖师闻言暗喜，道：“这等说，却是个天地生成的。 |
| 纵身 | zòng shēn / to leap up, spring into the air | ok | ”猴王纵身跳起，拐呀拐的走了两遍。 |
| 虽是 | suī shì / although, even though | ok | 祖师笑道：“你身躯虽是鄙陋，却像个食松果的猢狲。 |
| 鄙陋 | bǐ lòu / coarse and unrefined in appearance | ok | 祖师笑道：“你身躯虽是鄙陋，却像个食松果的猢狲。 |
| 松果 | sōng guǒ / pine cone | ok | 祖师笑道：“你身躯虽是鄙陋，却像个食松果的猢狲。 |
| 猢狲 | hú sūn / macaque, monkey | ok | 祖师笑道：“你身躯虽是鄙陋，却像个食松果的猢狲。 |
| 猢 | hú / the character "hu," first half of "húsūn" (macaque) — proposed as a surname | ok | 我与你就身上取个姓氏，意思教你姓‘猢’。 |
| 傍 | bàng / side radical/component of a written character (here, the "animal" radical) | fix|word|páng|side component of a written character (here the "animal" radical) | 猢字去了个兽傍，乃是个古月。 |
| 狲 | sūn / the character "sun," second half of "húsūn" (macaque) — proposed as a surname | ok | 老阴不能化育，教你姓‘狲’倒好。 |
| 方知 | fāng zhī / only now realize, just now understand | ok | 今日方知姓也。 |
| 慈悲 | cí bēi / mercy, compassion | ok | 万望师父慈悲，既然有姓，再乞赐个名字，却好呼唤。 |
| 起名 | qǐ míng / to give a name, to name someone | ok | ”祖师道：“我门中有十二个字，分派起名，到你乃第十辈… |
| 智 | zhì / wisdom (one of twelve generation characters used for disciples' names) | ok | ”祖师道：“乃广、大、智、慧、真、如、性、海、颖、悟… |
| 慧 | huì / intelligent, wise | ok | ”祖师道：“乃广、大、智、慧、真、如、性、海、颖、悟… |
| 颖 | yǐng / clever, outstanding, gifted | ok | ”祖师道：“乃广、大、智、慧、真、如、性、海、颖、悟… |
| 悟 | wù / to comprehend, to awaken spiritually | ok | ”祖师道：“乃广、大、智、慧、真、如、性、海、颖、悟… |
| 法名 | fǎ míng / a Buddhist or Daoist monastic name | ok | 与你起个法名叫做‘孙悟空’，好么？ |

### name (28)

| word | verdict | confirm | sentence |
|---|---|---|---|
| 盘古 | Pán gǔ / Pangu — mythical being who separated heaven and earth, creating the world. | ok | 自从盘古破鸿濛，开辟从兹清浊辨。 |
| 易 | yì / the Book of Changes (I Ching), the ancient divination classic being quoted | ok | 《易》曰：“大哉乾元！ |
| 乾 | qián / Qian, the first trigram/hexagram of the I Ching, symbolizing heaven | ok | 《易》曰：“大哉乾元！ |
| 三皇 | sān huáng / The Three Sovereigns — legendary rulers of high antiquity who governed the world. | ok | 感盘古开辟，三皇治世，五帝定伦，世界之间，遂分为四大… |
| 五帝 | wǔ dì / The Five Emperors — legendary sage-rulers who established human order and ethics. | ok | 感盘古开辟，三皇治世，五帝定伦，世界之间，遂分为四大… |
| 东胜 | Dōngshèng / Purvavideha — the Eastern Continent (one of the four continents; full name Dongsheng Shenzhou, "East Superior Divine Continent"). | ok | 感盘古开辟，三皇治世，五帝定伦，世界之间，遂分为四大… |
| 花果山 | Huāguǒ Shān / Flower-Fruit Mountain — the mountain home where the story's monkey hero is born. | ok | 国近大海，海中有一座名山，唤为花果山。 |
| 东海 | Dōng Hǎi / the East Sea — one of the four mythological seas encircling the world | ok | 水火方隅高积上，东海之处耸崇巅。 |
| 玉皇 | Yù huáng / the Jade Emperor, supreme ruler of Heaven in the story | ok | 惊动高天上圣大慈仁者玉皇大天尊玄穹高上帝，驾座金阙云… |
| 上帝 | Shàng dì / "Most High Emperor" — closing honorific in the Jade Emperor's full title here | ok | 惊动高天上圣大慈仁者玉皇大天尊玄穹高上帝，驾座金阙云… |
| 千里眼 | Qiān lǐ yǎn / Thousand-Mile Eye, the Jade Emperor's far-seeing sentinel | ok | 惊动高天上圣大慈仁者玉皇大天尊玄穹高上帝，驾座金阙云… |
| 顺风耳 | Shùn fēng ěr / Fair Wind Ear, the Jade Emperor's keen-hearing sentinel | ok | 惊动高天上圣大慈仁者玉皇大天尊玄穹高上帝，驾座金阙云… |
| 南天门 | Nán tiān mén / the South Gate of Heaven | ok | 惊动高天上圣大慈仁者玉皇大天尊玄穹高上帝，驾座金阙云… |
| 玉帝 | Yù Dì / the Jade Emperor, supreme ruler of heaven | ok | ”玉帝垂赐恩慈曰：“下方之物，乃天地精华所生，不足为… |
| 水帘洞 | shuǐ lián dòng / Water Curtain Cave — the stone monkey's new home behind a waterfall on Flower-Fruit Mountain | fix|name|shuǐ lián dòng|Water Curtain Cave (the monkeys' home on Flower-Fruit Mountain) | 只见正当中有一石碣，碣上有一行楷书大字，镌著“花果山… |
| 猴王 | Hóu wáng / the Monkey King — Sun Wukong, protagonist of the novel | ok | ”猴王道：“我虽在欢喜之时，却有一点儿远虑，故此烦恼… |
| 齐天大圣 | Qí tiān Dà shèng / Great Sage Equal to Heaven — the title Sun Wukong later claims for himself | ok | 这句话，顿教跳出轮回网，致使齐天大圣成。 |
| 元龙 | yuán lóng / an accomplished immortal/sage — one who has attained the Way (poetic epithet, not a specific character in this story) | fix|word|yuán lóng|one who has attained the Way; a realized immortal | 有分有缘休俗愿，无忧无虑会元龙。 |
| 阎君 | Yán jūn / Yama, the King of Hell in Buddhist/folk belief | ok | 只愁衣食耽劳碌，何怕阎君就取勾。 |
| 长城 | Cháng chéng / the Great Wall of China | ok | 在于南赡部洲，串长城，游小县，不觉八九年馀。 |
| 西洋 | Xī yáng / the Western Ocean — the far western seas of the story's mythical geography | ok | 忽行至西洋大海，他想著海外必有神仙。 |
| 西海 | Xī Hǎi / the Western Sea — one of the four seas of Buddhist cosmology, not the Yellow Sea | ok | 独自个依前作筏，又飘过西海，直至西牛贺洲地界。 |
| 瀛 | yíng / Yingzhou — one of the mythical isles of immortals, paired here with Penglai (蓬) | ok | 奇花瑞草，四时不谢赛蓬瀛。 |
| 灵台 | Líng tái / part of the name of the mountain where the sage lives (Mount Lingtai Fangcun); literally "Spirit Platform," a term for the heart/mind | fix|name|Líng tái|Lingtai, "Spirit Platform"; part of the mountain's name | 此山叫做灵台方寸山，山中有座斜月三星洞，那洞中有一个… |
| 菩提 | Pútí / Bodhi — the Patriarch who becomes Sun Wukong's teacher | ok | 直至瑶台之下，见那菩提祖师端坐在台上，两边有三十个小… |
| 孙 | Sūn / the surname "Sun," given to the Monkey King here — becomes Sun Wukong's family name | ok | 教你姓‘孙’罢。 |
| 孙悟空 | Sūn Wùkōng / Sun Wukong — the Monkey King, protagonist of the novel | ok | 与你起个法名叫做‘孙悟空’，好么？ |
| 悟空 | Wùkōng / Sun Wukong's given name, used alone — refers to the Monkey King | fix|word|wù kōng|to awaken to emptiness — the pun behind the name Wukong | 鸿濛初辟原无姓，打破顽空须悟空。 |

### artifact (26)

| word | verdict | confirm | sentence |
|---|---|---|---|
| 有水 | "有水" is just "have" + "water" from a list ("there is water, there is fire..."), not a standalone vocabulary word | ok | 再五千四百岁，正当丑会，重浊下凝，有水，有火，有山，… |
| 芦洲 | Bad segmentation — 芦 belongs with 北俱芦洲 (Uttarakuru, the Northern Continent), not with 洲 forming a separate word "芦洲"; the dictionary's Taiwan place-name sense is irrelevant here. | ok | 感盘古开辟，三皇治世，五帝定伦，世界之间，遂分为四大… |
| 威宁 | Bad segmentation — 威 and 宁 here are two separate descriptive words in a parallel verse line ("its might dominates..., its calm pacifies..."), not the Guizhou place name Weining. | ok | 势镇汪洋，威宁瑶海。 |
| 瑶海 | Bad segmentation — 瑶海 splits across a parallel verse construction (瑶-related image + 海 "sea"); the dictionary's Hefei district-name sense is irrelevant here. | fix|word|yáo hǎi|Jade sea — poetic term for a shimmering, gemlike ocean (parallel to 汪洋 in the preceding line). | 势镇汪洋，威宁瑶海。 |
| 锦 | mis-segmented; the real word here is 锦鸡 "golden pheasant" — 锦 alone just means "brocade" | fix|word|jǐn|brocade; brightly colored (here part of 锦鸡 "golden pheasant") | 峰头时听锦鸡鸣，石窟每观龙出入。 |
| 就学 | not a real compound here — 就 ("then") belongs with the earlier clause, and 学 ("learn") pairs separately with 爬 and 走 ("learn to crawl, learn to walk") | ok | 便就学爬学走，拜了四方。 |
| 所生 | not the CEDICT noun "parents" — this is a verb pattern (X 所生) meaning "engendered/produced by," as in "born of the essence of heaven and earth" | ok | ”玉帝垂赐恩慈曰：“下方之物，乃天地精华所生，不足为… |
| 邷 | bad segmentation — standalone 邷 has no meaning here; it's part of the fixed game-name phrase 邷麼兒/邷么儿 | ok | 抛弹子，邷么儿； |
| 潺 | 潺 and 湲 only occur here as the compound 潺湲 (murmuring, rushing sound of water); not meaningful split apart | fix|artifact|chán|bound form; only in 潺湲 (murmuring, rushing water) | 潺湲名瀑布，真似挂帘帷。 |
| 湲 | see 潺湲 note at item 2 — 湲 is the second half of the same compound | fix|artifact|yuán|bound form; only in 潺湲 (murmuring, rushing water) | 潺湲名瀑布，真似挂帘帷。 |
| 得来 | not the dictionary compound "得来" (to obtain); here it's 得 (potential-mood particle) + 来 (directional complement), split out of 进得来/出得去 ("can get in, can get out") | fix|artifact|de lái|not a word here; split from 进得来 = 进 + 得 (potential particle) + 来 (directional complement) | ’你们才说有本事进得来，出得去，不伤身体者，就拜他为… |
| 阎 | bad segmentation — 阎 here is part of 阎浮(世界), a transliteration of Sanskrit "Jambu" (Jambudvipa, the mortal world); 阎 alone doesn't carry this meaning | fix|artifact|yán|segmentation error: part of Yanfu (Jambudvipa), the mortal world; not a standalone word here | ”猿猴道：“他只在阎浮世界之中，古洞仙山之内。 |
| 黄皮 | not really a standalone word here — "黄皮" modifies "柿子" (persimmon) to mean "yellow-skinned," not the dictionary fruit "wampee" | ok | 红囊黑子熟西瓜，四瓣黄皮大柿子。 |
| 丹 | bad segmentation — 丹 is split from its partner character in 丹砂 ("cinnabar"), the actual unit of meaning here | ok | 石榴裂破，丹砂粒现火晶珠； |
| 奈 | the given senses don't fit — here 奈 stands for 柰, an old name for a type of crabapple/apple, not covered by the entries shown | fix|word|nài|crabapple (here writing 柰) | 榛松榧奈满盘盛，橘蔗柑橙盈案摆。 |
| 径向 | "径" (straight, directly) + "向" (toward) here modify the verb phrase "toward the sea waves"; not the modern physics compound "radial (direction)" — bad segmentation | fix|artifact|jìng xiàng|segmentation error: two separate words, "directly" + "toward", not the modern compound "radial" | ”果独自登筏，尽力撑开，飘飘荡荡，径向大海波中，趁天… |
| 学人 | Not the dictionary word "学人" (scholar). Here 学 is a verb "imitate" acting on 人 as its object across a larger phrase (学人穿... = "imitated humans by putting [clothes] on his body"), reflecting the monkey copying human behavior — bad segmentation. | ok | 将那跑不动的拿住一个，剥了他的衣裳，也学人穿在身上。 |
| 名为 | Not the dictionary word "名为" (to be called). The text has parallel 为名...为利 ("for fame...for profit"); "名为" here is just an accidental overlap of 为名 and 为利, not a real word — bad segmentation. | ok | 见世人都是为名为利之徒，更无一个为身命者。 |
| 著 | Here 著 is the aspect particle zhe (=着, marking ongoing action, as in 想著 "pondering"), not the zhù/zhuó senses listed — a dictionary-entry mismatch, not real vocabulary | fix|artifact|zhe|Dictionary mismatch: here 著 is the aspect particle zhe (=着), marking ongoing action in 想著 "pondering" — not the zhù/zhuó senses listed. Not real vocabulary. | 忽行至西洋大海，他想著海外必有神仙。 |
| 庭 | here 庭 is just the second syllable of the title 黄庭 ("Huangting," a Daoist classic being expounded); it isn't a standalone word in this sentence | fix|artifact|tíng|second syllable of "Huangting," a Daoist scripture | 相逢处，非仙即道，静坐讲《黄庭》。 |
| 不误 | not the 照…不誤 "keep doing X regardless" construction — here 不 is a rhetorical negation and 誤(了) is the verb "to ruin/delay," split across "却不…了": bad segmentation | ok | 假若我与你去了，却不误了我的生意？ |
| 摇光 | not the star name Alkaid — here 摇(shake)+光(light) is a verb-object pair describing sun/moon shimmering light: bad segmentation | ok | 烟霞散彩，日月摇光。 |
| 花布 | not "printed cloth" — 布 here is the verb "to spread/lay out" and 锦 is "brocade," following 奇花: bad segmentation | ok | 门外奇花布锦，桥边瑶草喷香。 |
| 一声 | not a real vocabulary word here — 一 ("one") + 声 ("sound") combine with 呀的 to mean "with a creak"; the CEDICT sense (name of a tone) doesn't apply | fix|artifact|yī shēng|not a vocabulary item here — just 一 "one" + 声 "sound" inside 呀的一声 "with a creak"; the CEDICT tone-name sense doesn't apply | 少顷间，只听得呀的一声，洞门开处，里面走出一个仙童，… |
| 外长 | not a real word here — the line splits as 物外 "beyond material things" + 长年 "eternal years", not 外长 "foreign minister" | ok | 物外长年客，山中永寿童。 |
| 道学 | not a real word here — the line splits as 访道 "seek the Way" + 学仙 "study immortality", not 道学 "Confucian ethics" | ok | ”猴王扑的跳下树来，上前躬身道：“仙童，我是个访道学… |

## Phase C — not in CEDICT (routing; 83 fixed by confirm)

### name (12)

| token | verdict | confirm | sentence |
|---|---|---|---|
| 西游 | Xī Yóu / "Journey West" — here part of the book's own title 西游释厄传, an early name for this novel | ok | 欲知造化会元功，须看《西游释厄传》。 |
| 释厄传 | Shì È Zhuàn / "Tale of Deliverance from Trials" — second half of the title 西游释厄传 | ok | 欲知造化会元功，须看《西游释厄传》。 |
| 邵康节 | Shào Kāngjié / Shao Kangjie, courtesy name of Song-dynasty philosopher Shao Yong (邵雍), whose cosmological verse from 皇极经世 is quoted here | fix|name|Shào Kāngjié|Shao Kangjie, posthumous title (谥号) of Song Neo-Confucian philosopher Shao Yong (邵雍, 1011–1077); his courtesy name was 尧夫. The couplet quoted here is from his poem 冬至吟 (伊川击壤集); his cosmological cycle of 元会运世 comes from 皇极经世 | 邵康节曰：“冬至子之半，天心无改移。 |
| 神洲 | Dōngshèng Shénzhōu / fragment of 东胜神洲, one of the four continents in the novel's cosmology (Purvavideha), where the Stone Monkey's story begins | ok | 感盘古开辟，三皇治世，五帝定伦，世界之间，遂分为四大… |
| 牛贺洲 | Xīniú Hèzhōu / fragment of 西牛贺洲, the western continent (Aparagodānīya) in the novel's cosmology | ok | 感盘古开辟，三皇治世，五帝定伦，世界之间，遂分为四大… |
| 部洲 | Nánshàn Bùzhōu / fragment of 南赡部洲, the southern continent (Jambudvīpa) representing the human world in the novel's cosmology | fix|word|bù zhōu|continent (Sanskrit dvīpa); a common noun here, as in 四大部洲 "the four great continents" of Buddhist cosmology, not only a fragment of 南赡部洲 | 感盘古开辟，三皇治世，五帝定伦，世界之间，遂分为四大… |
| 傲来国 | Àolái Guó / Aolai Kingdom, coastal land near Flower-Fruit Mountain | ok | 海外有一国土，名曰傲来国。 |
| 石猴 | Shí Hóu / "Stone Monkey" — epithet of the newborn monkey (later Sun Wukong) born from the stone egg | fix|word|shí hóu|stone monkey — a monkey formed from stone; here a common noun ("化作一个石猴"), later an epithet for Sun Wukong | 因见风，化作一个石猴，五官俱备，四肢皆全。 |
| 铁板桥 | Tiěbǎnqiáo / the Iron-Slab Bridge, the stone bridge found inside the Water Curtain Cave | fix|word|tiěbǎnqiáo|iron-plate bridge (a common noun here — 是座铁板桥, not a proper name) | 他住了身，定了神，仔细再看，原来是座铁板桥。 |
| 美猴王 | Měi Hóu Wáng / "Handsome Monkey King" — title Sun Wukong takes as ruler of the monkeys | ok | 自此，石猿高登王位，将“石”字儿隐了，遂称“美猴王”… |
| 满庭芳 | Mǎn Tíng Fāng / "Courtyard Full of Fragrance" — a cípái (lyric-tune title); here the name of the woodcutter's song | ok | ”樵夫笑道：“实不瞒你说，这个词名做《满庭芳》，乃一… |
| 须菩提 | Xūpútí / Subhuti — name borrowed from a disciple of the Buddha, here the Patriarch who becomes Sun Wukong's teacher | ok | 此山叫做灵台方寸山，山中有座斜月三星洞，那洞中有一个… |

### artifact (368)

| token | verdict | confirm | sentence |
|---|---|---|---|
| 破鸿 | 破 / 鸿濛 | ok | 自从盘古破鸿濛，开辟从兹清浊辨。 |
| 濛 | 破 / 鸿濛 | ok | 自从盘古破鸿濛，开辟从兹清浊辨。 |
| 仰至仁 | 仰 / 至仁 | ok | 覆载群生仰至仁，发明万物皆成善。 |
| 成善 | 成 / 善 | ok | 覆载群生仰至仁，发明万物皆成善。 |
| 会元功 | 会元 / 功 | ok | 欲知造化会元功，须看《西游释厄传》。 |
| 之数 | 之 / 数 | ok | 盖闻天地之数，有十二万九千六百岁为一元。 |
| 乃子 | 乃 / 子 | ok | 将一元分为十二会，乃子、丑、寅、卯、辰、巳、午、未、… |
| 一万八 | 一万 / 八百 | ok | 每会该一万八百岁。 |
| 而卯 | 而 / 卯 | ok | 寅不通光，而卯则日出； |
| 未则西 | 未 / 则|西 | ok | 日午天中，而未则西蹉； |
| 而人定 | 而 / 人定 | ok | 申时晡，而日落酉，戌黄昏，而人定亥。 |
| 到戌会 | 到 / 戌会 | ok | 譬于大数，若到戌会之终，则天地昏曚而万物否矣。 |
| 之终 | 之 / 终 | ok | 譬于大数，若到戌会之终，则天地昏曚而万物否矣。 |
| 否矣 | 否 / 矣 | ok | 譬于大数，若到戌会之终，则天地昏曚而万物否矣。 |
| 交亥会 | 交 / 亥会 | ok | 再去五千四百岁，交亥会之初，则当黑暗，而两间人物俱无… |
| 近子 | 近 / 子 | ok | 又五千四百岁，亥会将终，贞下起元，近子之会，而复逐渐… |
| 之会 | 之 / 会 | ok | 又五千四百岁，亥会将终，贞下起元，近子之会，而复逐渐… |
| 子之半 | 子 / 之|半 | ok | 邵康节曰：“冬至子之半，天心无改移。 |
| 初动处 | 初动 / 处 | fix|artifact|初|动|处 | 一阳初动处，万物未生时。 |
| 未生 | 未 / 生 | ok | 一阳初动处，万物未生时。 |
| 天始 | 天 / 始 | ok | ”到此，天始有根。 |
| 有星 | 有 / 星 | ok | 再五千四百岁，正当子会，轻清上腾，有日，有月，有星，… |
| 有辰 | 有 / 辰 | ok | 再五千四百岁，正当子会，轻清上腾，有日，有月，有星，… |
| 天开 | 天 / 开 | ok | 故曰，天开于子。 |
| 于子 | 于 / 子 | ok | 故曰，天开于子。 |
| 近丑 | 近 / 丑 | ok | 又经五千四百岁，子会将终，近丑之会，而逐渐坚实。 |
| 地始 | 地 / 始 | ok | ”至此，地始凝结。 |
| 有火 | 有 / 火 | ok | 再五千四百岁，正当丑会，重浊下凝，有水，有火，有山，… |
| 有山 | 有 / 山 | ok | 再五千四百岁，正当丑会，重浊下凝，有水，有火，有山，… |
| 有石 | 有 / 石 | ok | 再五千四百岁，正当丑会，重浊下凝，有水，有火，有山，… |
| 有土 | 有 / 土 | ok | 再五千四百岁，正当丑会，重浊下凝，有水，有火，有山，… |
| 地辟 | 地 / 辟 | ok | 故曰，地辟于丑。 |
| 终而寅会 | 终 / 而|寅会 | ok | 又经五千四百岁，丑会终而寅会之初，发生万物。 |
| 历曰 | 历 / 曰 | ok | 历曰：“天气下降，地气上升； |
| 群物皆生 | 群物 / 皆|生 | ok | 天地交合，群物皆生。 |
| 天清 | 天 / 清 | ok | ”至此，天清地爽，阴阳交合。 |
| 地爽 | 地 / 爽 | ok | ”至此，天清地爽，阴阳交合。 |
| 生兽 | 生 / 兽 | ok | 再五千四百岁，正当寅会，生人，生兽，生禽，正谓天地人… |
| 生禽 | 生 / 禽 | ok | 再五千四百岁，正当寅会，生人，生兽，生禽，正谓天地人… |
| 正谓 | 正 / 谓 | ok | 再五千四百岁，正当寅会，生人，生兽，生禽，正谓天地人… |
| 于寅 | 于 / 寅 | ok | 故曰，人生于寅。 |
| 这部 | 这 / 部 | ok | 这部书单表东胜神洲。 |
| 书单 | 书 / 单 | ok | 这部书单表东胜神洲。 |
| 国近 | 国 / 近 | ok | 国近大海，海中有一座名山，唤为花果山。 |
| 此山 | 此 / 山 | ok | 此山乃十洲之祖脉，三岛之来龙，自开清浊而立，鸿濛判后… |
| 乃十洲 | 乃 / 十洲 | ok | 此山乃十洲之祖脉，三岛之来龙，自开清浊而立，鸿濛判后… |
| 之来 | 之 / 来龙 | ok | 此山乃十洲之祖脉，三岛之来龙，自开清浊而立，鸿濛判后… |
| 自开 | 自 / 开 | ok | 此山乃十洲之祖脉，三岛之来龙，自开清浊而立，鸿濛判后… |
| 而立 | 而 / 立 | ok | 此山乃十洲之祖脉，三岛之来龙，自开清浊而立，鸿濛判后… |
| 判后 | 判 / 后 | ok | 此山乃十洲之祖脉，三岛之来龙，自开清浊而立，鸿濛判后… |
| 而成 | 而 / 成 | ok | 此山乃十洲之祖脉，三岛之来龙，自开清浊而立，鸿濛判后… |
| 好山 | 好 / 山 | ok | 真个好山！ |
| 鱼入穴 | 鱼 / 入穴 | fix|artifact|鱼|入|穴 | 势镇汪洋，潮涌银山鱼入穴； |
| 波翻 | 波 / 翻 | ok | 威宁瑶海，波翻雪浪蜃离渊。 |
| 雪浪蜃离渊 | 雪浪 / 蜃|离渊 | fix|artifact|雪|浪|蜃|离|渊 | 威宁瑶海，波翻雪浪蜃离渊。 |
| 高积 | 高 / 积 | ok | 水火方隅高积上，东海之处耸崇巅。 |
| 耸崇巅 | 耸 / 崇巅 | fix|artifact|耸|崇|巅 | 水火方隅高积上，东海之处耸崇巅。 |
| 双鸣 | 双 / 鸣 | ok | 丹崖上，彩凤双鸣； |
| 独卧 | 独 / 卧 | ok | 削壁前，麒麟独卧。 |
| 每观龙 | 每 / 观|龙 | ok | 峰头时听锦鸡鸣，石窟每观龙出入。 |
| 有寿鹿 | 有 / 寿鹿 | fix|artifact|有|寿|鹿 | 林中有寿鹿仙狐，树上有灵禽玄鹤。 |
| 瑶草奇花 | 瑶草 / 奇花 | ok | 瑶草奇花不谢，青松翠柏长春。 |
| 留云 | 留 / 云 | ok | 仙桃常结果，修竹每留云。 |
| 那座 | 那 / 座 | ok | 那座山正当顶上，有一块仙石。 |
| 其石 | 其 / 石 | ok | 其石有三丈六尺五寸高，有二丈四尺围圆。 |
| 按政历 | 按 / 政历 | ok | 二丈四尺围圆，按政历二十四气。 |
| 盖自 | 盖 / 自 | ok | 盖自开辟以来，每受天真地秀，日精月华，感之既久，遂有… |
| 感之 | 感 / 之 | ok | 盖自开辟以来，每受天真地秀，日精月华，感之既久，遂有… |
| 既久 | 既 / 久 | ok | 盖自开辟以来，每受天真地秀，日精月华，感之既久，遂有… |
| 之意 | 之 / 意 | ok | 盖自开辟以来，每受天真地秀，日精月华，感之既久，遂有… |
| 内育 | 内 / 育 | ok | 内育仙胞，一日迸裂，产一石卵，似圆球样大。 |
| 产一石 | 产 / 一|石卵 | ok | 内育仙胞，一日迸裂，产一石卵，似圆球样大。 |
| 样大 | 样 / 大 | ok | 内育仙胞，一日迸裂，产一石卵，似圆球样大。 |
| 因见 | 因 / 见 | ok | 因见风，化作一个石猴，五官俱备，四肢皆全。 |
| 爬学 | 学爬 / 学走 | ok | 便就学爬学走，拜了四方。 |
| 目运 | 目 / 运 | ok | 目运两道金光，射冲斗府。 |
| 射冲斗府 | 射冲 / 斗府 | ok | 目运两道金光，射冲斗府。 |
| 圣大 | 上圣 / 大慈 | ok | 惊动高天上圣大慈仁者玉皇大天尊玄穹高上帝，驾座金阙云… |
| 天尊玄 | 大天尊 / 玄穹高上帝 | ok | 惊动高天上圣大慈仁者玉皇大天尊玄穹高上帝，驾座金阙云… |
| 穹高 | 玄穹 / 高上帝 | ok | 惊动高天上圣大慈仁者玉皇大天尊玄穹高上帝，驾座金阙云… |
| 金阙云 | 金阙云宫 / 灵霄宝殿 | ok | 惊动高天上圣大慈仁者玉皇大天尊玄穹高上帝，驾座金阙云… |
| 宫灵霄 | 金阙云宫 / 灵霄宝殿 | ok | 惊动高天上圣大慈仁者玉皇大天尊玄穹高上帝，驾座金阙云… |
| 光焰 | 金光 / 焰焰 | ok | 惊动高天上圣大慈仁者玉皇大天尊玄穹高上帝，驾座金阙云… |
| 二将果 | 二将 / 果 | ok | 二将果奉旨出门外，看的真，听的明。 |
| 神洲海 | 神洲 / 海 | fix|artifact|东胜神洲|海东 | 须臾回报道：“臣奉旨观听金光之处，乃东胜神洲海东傲来… |
| 东傲 | 东 / 傲来 | fix|artifact|海东|傲来 | 须臾回报道：“臣奉旨观听金光之处，乃东胜神洲海东傲来… |
| 之界 | 之 / 界 | ok | 须臾回报道：“臣奉旨观听金光之处，乃东胜神洲海东傲来… |
| 石产 | 石 / 产 | ok | 须臾回报道：“臣奉旨观听金光之处，乃东胜神洲海东傲来… |
| 眼运 | 眼 / 运 | ok | 须臾回报道：“臣奉旨观听金光之处，乃东胜神洲海东傲来… |
| 垂赐恩 | 垂赐 / 恩慈 | ok | ”玉帝垂赐恩慈曰：“下方之物，乃天地精华所生，不足为… |
| 慈曰 | 恩慈 / 曰 | ok | ”玉帝垂赐恩慈曰：“下方之物，乃天地精华所生，不足为… |
| 之物 | 之 / 物 | ok | ”玉帝垂赐恩慈曰：“下方之物，乃天地精华所生，不足为… |
| 为异 | 为 / 异 | ok | ”玉帝垂赐恩慈曰：“下方之物，乃天地精华所生，不足为… |
| 那猴 | 那 / 猴 | ok | 那猴在山中，却会行走跳跃，食草木，饮涧泉，采山花，觅… |
| 却会 | 却 / 会 | ok | 那猴在山中，却会行走跳跃，食草木，饮涧泉，采山花，觅… |
| 饮涧泉 | 饮 / 涧泉 | ok | 那猴在山中，却会行走跳跃，食草木，饮涧泉，采山花，觅… |
| 觅树果 | 觅 / 树果 | ok | 那猴在山中，却会行走跳跃，食草木，饮涧泉，采山花，觅… |
| 朝游峰 | 朝 / 游|峰 | fix|artifact|朝游|峰 | 夜宿石崖之下，朝游峰洞之中。 |
| 咬又 | 咬 / 又 | ok | 捉虱子，咬又掐； |
| 擦的擦 | 擦 / 的|擦 | ok | 挨的挨，擦的擦； |
| 压的压 | 压 / 的|压 | ok | 推的推，压的压； |
| 拉的拉 | 拉 / 的|拉 | ok | 扯的扯，拉的拉：青松林下任他顽，绿水涧边随洗濯。 |
| 那股 | 那 / 股 | ok | 见那股涧水奔流，真个似滚瓜涌溅。 |
| 似滚瓜 | 似 / 滚瓜 | ok | 见那股涧水奔流，真个似滚瓜涌溅。 |
| 顺涧边 | 顺 / 涧边 | ok | 我们今日赶闲无事，顺涧边往上溜头寻看源流，耍子去耶！ |
| 上溜头 | 上 / 溜头 | fix|word|shàng liù tóu|the upper reaches of a stream; upstream (dialect; cf. 下溜头 downstream) | 我们今日赶闲无事，顺涧边往上溜头寻看源流，耍子去耶！ |
| 去耶 | 去 / 耶 | ok | 我们今日赶闲无事，顺涧边往上溜头寻看源流，耍子去耶！ |
| 喊一声 | 喊 / 一声 | ok | ”喊一声，都拖男挈女，呼弟呼兄，一齐跑来，顺涧爬山，… |
| 男挈女 | 男 / 挈女 | fix|artifact|男|挈|女 | ”喊一声，都拖男挈女，呼弟呼兄，一齐跑来，顺涧爬山，… |
| 呼弟 | 呼 / 弟 | ok | ”喊一声，都拖男挈女，呼弟呼兄，一齐跑来，顺涧爬山，… |
| 呼兄 | 呼 / 兄 | ok | ”喊一声，都拖男挈女，呼弟呼兄，一齐跑来，顺涧爬山，… |
| 顺涧 | 顺 / 涧 | ok | ”喊一声，都拖男挈女，呼弟呼兄，一齐跑来，顺涧爬山，… |
| 见那 | 见 / 那 | ok | 但见那： |
| 千寻雪浪 | 千寻 / 雪浪 | ok | 一派白虹起，千寻雪浪飞。 |
| 江月照 | 江月 / 照 | ok | 海风吹不断，江月照还依。 |
| 分青嶂 | 分 / 青嶂 | ok | 冷气分青嶂，馀流润翠微。 |
| 流润 | 流 / 润 | ok | 冷气分青嶂，馀流润翠微。 |
| 挂帘 | 挂 / 帘帷 | fix|artifact|挂|帘 | 潺湲名瀑布，真似挂帘帷。 |
| 之波 | 之 / 波 | ok | 原来此处远通山脚之下，直接大海之波。 |
| 不伤 | 不 / 伤 | ok | ”又道：“那一个有本事的，钻进去寻个源头出来，不伤身… |
| 是他 | 是 / 他 | ok | 也是他： |
| 运通 | 运 / 通 | ok | 今日芳名显，时来大运通。 |
| 王遣入 | 王 / 遣入 | fix|artifact|王|遣|入 | 有缘居此地，王遣入仙宫。 |
| 忽睁睛 | 忽 / 睁睛 | ok | 你看他瞑目蹲身，将身一纵，径跳入瀑布泉中，忽睁睛抬头… |
| 无波 | 无 / 波 | ok | 你看他瞑目蹲身，将身一纵，径跳入瀑布泉中，忽睁睛抬头… |
| 之水 | 之 / 水 | ok | 桥下之水，冲贯于石窍之间，倒挂流出去，遮闭了桥门。 |
| 冲贯于 | 冲贯 / 于 | ok | 桥下之水，冲贯于石窍之间，倒挂流出去，遮闭了桥门。 |
| 翠藓堆 | 翠藓 / 堆 | ok | 翠藓堆蓝，白云浮玉，光摇片片烟霞。 |
| 浮玉 | 浮 / 玉 | ok | 翠藓堆蓝，白云浮玉，光摇片片烟霞。 |
| 光摇 | 光 / 摇 | ok | 翠藓堆蓝，白云浮玉，光摇片片烟霞。 |
| 滑凳 | 滑 / 凳板 | ok | 虚窗静室，滑凳板生花。 |
| 存火迹 | 存 / 火迹 | ok | 锅灶傍崖存火迹，樽罍靠案见殽渣。 |
| 更堪 | 更 / 堪夸 | ok | 石座石床真可爱，石盆石碗更堪夸。 |
| 常带 | 常 / 带 | ok | 几树青松常带雨，浑然像个人家。 |
| 过桥 | 跳过 / 桥中间 | ok | 看罢多时，跳过桥中间，左右观看。 |
| 中有 | 中 / 有 | ok | 只见正当中有一石碣，碣上有一行楷书大字，镌著“花果山… |
| 有多深 | 有 / 多深 | ok | 水有多深？ |
| 没水 | 没 / 水 | ok | 没水！ |
| 有花 | 有 / 花 | ok | 桥边有花有树，乃是一座石房。 |
| 之气 | 之 / 气 | ok | 我们都进去住，也省得受老天之气。 |
| 有处 | 有 / 处躲 | fix|artifact|有|处 | 刮风有处躲，下雨好存身。 |
| 年秀 | 年年 / 秀 | ok | 松竹年年秀，奇花日日新。 |
| 都道 | 都 / 道 | ok | 都道：“你还先走，带我们进去，进去。 |
| 猴有 | 猴 / 有 | ok | ”那些猴有胆大的，都跳进去了； |
| 抢盆夺 | 抢盆 / 夺碗 | ok | 跳过桥头，一个个抢盆夺碗，占灶争床，搬过来，移过去，… |
| 争床 | 争 / 床 | ok | 跳过桥头，一个个抢盆夺碗，占灶争床，搬过来，移过去，… |
| 倦神 | 力倦 / 神疲 | ok | 跳过桥头，一个个抢盆夺碗，占灶争床，搬过来，移过去，… |
| 疲方止 | 疲 / 方止 | fix|artifact|疲|方|止 | 跳过桥头，一个个抢盆夺碗，占灶争床，搬过来，移过去，… |
| 出得 | 出得 / 去 | fix|artifact|出|得 | ’你们才说有本事进得来，出得去，不伤身体者，就拜他为… |
| 各享 | 各 / 享 | ok | 我如今进来又出去，出去又进来，寻了这一个洞天与列位安… |
| 之福 | 之 / 福 | ok | 我如今进来又出去，出去又进来，寻了这一个洞天与列位安… |
| 为王 | 为 / 王 | ok | 我如今进来又出去，出去又进来，寻了这一个洞天与列位安… |
| 伏无违 | 伏 / 无违 | ok | ”众猴听说，即拱伏无违，一个个序齿排班，朝上礼拜，都… |
| 都称 | 都 / 称 | ok | ”众猴听说，即拱伏无违，一个个序齿排班，朝上礼拜，都… |
| 高登 | 高 / 登 | ok | 自此，石猿高登王位，将“石”字儿隐了，遂称“美猴王”… |
| 遂称 | 遂 / 称 | ok | 自此，石猿高登王位，将“石”字儿隐了，遂称“美猴王”… |
| 借卵化 | 借卵 / 化 | ok | 借卵化猴完大道，假他名姓配丹成。 |
| 配丹成 | 配 / 丹成 | ok | 借卵化猴完大道，假他名姓配丹成。 |
| 不识 | 不 / 识 | ok | 内观不识因无相，外合明知作有形。 |
| 因无相 | 因 / 无相 | ok | 内观不识因无相，外合明知作有形。 |
| 称圣任 | 称圣 / 任 | ok | 历代人人皆属此，称王称圣任纵横。 |
| 朝游 | 朝 / 游 | ok | 朝游花果山，暮宿水帘洞，合契同情，不入飞鸟之丛，不从… |
| 暮宿 | 暮 / 宿 | ok | 朝游花果山，暮宿水帘洞，合契同情，不入飞鸟之丛，不从… |
| 不入 | 不 / 入 | ok | 朝游花果山，暮宿水帘洞，合契同情，不入飞鸟之丛，不从… |
| 之丛 | 之 / 丛 | ok | 朝游花果山，暮宿水帘洞，合契同情，不入飞鸟之丛，不从… |
| 春采 | 春 / 采 | ok | 春采百花为饮食，夏寻诸果作生涯。 |
| 夏寻 | 夏 / 寻 | ok | 春采百花为饮食，夏寻诸果作生涯。 |
| 诸果 | 诸 / 果 | ok | 春采百花为饮食，夏寻诸果作生涯。 |
| 栗延 | 栗 / 延 | ok | 秋收芋栗延时节，冬觅黄精度岁华。 |
| 冬觅 | 冬 / 觅 | ok | 秋收芋栗延时节，冬觅黄精度岁华。 |
| 泪来 | 泪 / 来 | ok | 一日，与群猴喜宴之间，忽然忧恼，堕下泪来。 |
| 之时 | 之 / 时 | ok | ”猴王道：“我虽在欢喜之时，却有一点儿远虑，故此烦恼… |
| 古洞 | 古 / 洞 | ok | 我等日日欢会，在仙山福地，古洞神洲，不伏麒麟辖，不伏… |
| 伏麒麟 | 伏 / 麒麟 | ok | 我等日日欢会，在仙山福地，古洞神洲，不伏麒麟辖，不伏… |
| 不伏 | 不 / 伏 | ok | 我等日日欢会，在仙山福地，古洞神洲，不伏麒麟辖，不伏… |
| 忧也 | 忧 / 也 | ok | 我等日日欢会，在仙山福地，古洞神洲，不伏麒麟辖，不伏… |
| 虽不归 | 虽 / 不归 | fix|artifact|虽|不|归 | ”猴王道：“今日虽不归人王法律，不惧禽兽威严，将来年… |
| 不惧 | 不 / 惧 | ok | ”猴王道：“今日虽不归人王法律，不惧禽兽威严，将来年… |
| 注天 | 注 / 天人 | ok | ”猴王道：“今日虽不归人王法律，不惧禽兽威严，将来年… |
| 此言 | 此 / 言 | ok | ”众猴闻此言，一个个掩面悲啼，俱以无常为虑。 |
| 俱以 | 俱 / 以 | ok | ”众猴闻此言，一个个掩面悲啼，俱以无常为虑。 |
| 为虑 | 为 / 虑 | ok | ”众猴闻此言，一个个掩面悲啼，俱以无常为虑。 |
| 那班部 | 那 / 班部 | ok | 只见那班部中，忽跳出一个通背猿猴，厉声高叫道：“大王… |
| 一个通 | 一个 / 通背猿猴 | ok | 只见那班部中，忽跳出一个通背猿猴，厉声高叫道：“大王… |
| 所管 | 所 / 管 | ok | 如今五虫之内，惟有三等名色不伏阎王老子所管。 |
| 辞汝等 | 辞 / 汝等 | ok | ”猴王闻之，满心欢喜道：“我明日就辞汝等下山，云游海… |
| 访此 | 访 / 此 | ok | ”猴王闻之，满心欢喜道：“我明日就辞汝等下山，云游海… |
| 阎君之 | 阎君 / 之 | ok | ”猴王闻之，满心欢喜道：“我明日就辞汝等下山，云游海… |
| 这句 | 这 / 句 | ok | 这句话，顿教跳出轮回网，致使齐天大圣成。 |
| 广寻些 | 广 / 寻|些 | ok | 我等明日越岭登山，广寻些果品，大设筵宴送大王也。 |
| 大设 | 大 / 设 | ok | 我等明日越岭登山，广寻些果品，大设筵宴送大王也。 |
| 众猴果 | 众猴 / 果 | ok | 次日，众猴果去采仙桃，摘异果，刨山药，斸黄精。 |
| 摘异果 | 摘 / 异果 | ok | 次日，众猴果去采仙桃，摘异果，刨山药，斸黄精。 |
| 酒仙 | 仙酒 / 仙肴 | ok | 芝兰香蕙，瑶草奇花，般般件件，整整齐齐，摆开石凳石桌… |
| 金丸珠 | 金丸 / 珠弹 | ok | 金丸珠弹，红绽黄肥。 |
| 弹腊 | 弹 / 腊樱桃 | ok | 金丸珠弹腊樱桃，色真甘美； |
| 色真 | 色 / 真 | ok | 金丸珠弹腊樱桃，色真甘美； |
| 黄肥熟 | 黄肥 / 熟 | ok | 红绽黄肥熟梅子，味果香酸。 |
| 果香 | 果 / 香 | ok | 红绽黄肥熟梅子，味果香酸。 |
| 肉甜 | 肉 / 甜 | ok | 鲜龙眼，肉甜皮薄； |
| 皮薄 | 皮 / 薄 | ok | 鲜龙眼，肉甜皮薄； |
| 小囊 | 小 / 囊 | ok | 火荔枝，核小囊红。 |
| 连枝献 | 连枝 / 献 | ok | 林檎碧实连枝献，枇杷缃苞带叶擎。 |
| 叶擎 | 叶 / 擎 | ok | 林檎碧实连枝献，枇杷缃苞带叶擎。 |
| 更解 | 更 / 解酲 | fix|artifact|更|解 | 兔头梨子鸡心枣，消渴除烦更解酲。 |
| 香桃烂杏 | 香桃 / 烂杏 | ok | 香桃烂杏，美甘甘似玉液琼浆； |
| 美甘甘似 | 美甘甘 / 似 | ok | 香桃烂杏，美甘甘似玉液琼浆； |
| 李杨梅 | 李 / 杨梅 | ok | 脆李杨梅，酸荫荫如脂酥膏酪。 |
| 如脂 | 如 / 脂 | ok | 脆李杨梅，酸荫荫如脂酥膏酪。 |
| 酥膏酪 | 酥 / 膏|酪 | ok | 脆李杨梅，酸荫荫如脂酥膏酪。 |
| 砂粒 | 砂 / 粒 | ok | 石榴裂破，丹砂粒现火晶珠； |
| 现火 | 现 / 火晶珠 | ok | 石榴裂破，丹砂粒现火晶珠； |
| 晶珠 | 火 / 晶珠 | ok | 石榴裂破，丹砂粒现火晶珠； |
| 肉团金 | 肉团 / 金玛瑙 | ok | 芋栗剖开，坚硬肉团金玛瑙。 |
| 可传 | 可 / 传 | ok | 胡桃银杏可传茶，椰子葡萄能做酒。 |
| 柑橙盈案 | 柑橙 / 盈案 | fix|artifact|柑|橙|盈案 | 榛松榧奈满盘盛，橘蔗柑橙盈案摆。 |
| 纵有 | 纵 / 有 | ok | 人间纵有珍馐味，怎比山猴乐更宁。 |
| 怎比山 | 怎比 / 山 | fix|artifact|怎比|山猴 | 人间纵有珍馐味，怎比山猴乐更宁。 |
| 猴乐 | 猴 / 乐 | fix|artifact|山猴|乐 | 人间纵有珍馐味，怎比山猴乐更宁。 |
| 更宁 | 更 / 宁 | ok | 人间纵有珍馐味，怎比山猴乐更宁。 |
| 群猴尊 | 群猴 / 尊 | ok | 群猴尊美猴王上坐，各依齿肩排于下边，一个个轮流上前奉… |
| 各依齿 | 各依 / 齿肩 | ok | 群猴尊美猴王上坐，各依齿肩排于下边，一个个轮流上前奉… |
| 排于 | 排 / 于 | ok | 群猴尊美猴王上坐，各依齿肩排于下边，一个个轮流上前奉… |
| 编作 | 编 / 作 | ok | 次日，美猴王早起，教：“小的们，替我折些枯松，编作筏… |
| 作篙 | 作 / 篙 | ok | 次日，美猴王早起，教：“小的们，替我折些枯松，编作筏… |
| 登筏 | 登 / 筏 | ok | ”果独自登筏，尽力撑开，飘飘荡荡，径向大海波中，趁天… |
| 趁天风 | 趁 / 天风 | ok | ”果独自登筏，尽力撑开，飘飘荡荡，径向大海波中，趁天… |
| 渡南 | 渡 / 南赡部洲 | ok | ”果独自登筏，尽力撑开，飘飘荡荡，径向大海波中，趁天… |
| 天产仙 | 天产 / 仙猴 | ok | 天产仙猴道行隆，离山驾筏趁天风。 |
| 离山 | 离 / 山 | ok | 天产仙猴道行隆，离山驾筏趁天风。 |
| 驾筏 | 驾 / 筏 | ok | 天产仙猴道行隆，离山驾筏趁天风。 |
| 寻仙道 | 寻 / 仙道 | ok | 飘洋过海寻仙道，立志潜心建大功。 |
| 休俗 | 休 / 俗愿 | ok | 有分有缘休俗愿，无忧无虑会元龙。 |
| 必遇 | 必 / 遇 | ok | 料应必遇知音者，说破源流万法通。 |
| 知音者 | 知音 / 者 | ok | 料应必遇知音者，说破源流万法通。 |
| 自登 | 自 / 登 | ok | 也是他运至时来，自登木筏之后，连日东南风紧，将他送到… |
| 岸前 | 岸 / 前 | ok | 也是他运至时来，自登木筏之后，连日东南风紧，将他送到… |
| 持篙 | 持 / 篙 | ok | 持篙试水，偶得浅水，弃了筏子，跳上岸来。 |
| 偶得 | 偶 / 得 | ok | 持篙试水，偶得浅水，弃了筏子，跳上岸来。 |
| 弃网 | 弃 / 网 | ok | 他走近前，弄个把戏，妆个𡤫虎，吓得那些人丢筐弃网，四… |
| 学人话 | 学 / 人话 | ok | 摇摇摆摆，穿州过府，在市廛中学人礼，学人话。 |
| 之道 | 之 / 道 | ok | 朝餐夜宿，一心里访问佛、仙、神圣之道，觅个长生不老之… |
| 之方 | 之 / 方 | ok | 朝餐夜宿，一心里访问佛、仙、神圣之道，觅个长生不老之… |
| 利之徒 | 利 / 之徒 | fix|artifact|利|之|徒 | 见世人都是为名为利之徒，更无一个为身命者。 |
| 身命者 | 身命 / 者 | ok | 见世人都是为名为利之徒，更无一个为身命者。 |
| 几时休 | 几时 / 休 | ok | 争名夺利几时休？ |
| 只愁 | 只 / 愁 | ok | 只愁衣食耽劳碌，何怕阎君就取勾。 |
| 何怕 | 何 / 怕 | ok | 只愁衣食耽劳碌，何怕阎君就取勾。 |
| 孙图 | 孙 / 图 | ok | 继子荫孙图富贵，更无一个肯回头。 |
| 游小县 | 游 / 小县 | ok | 在于南赡部洲，串长城，游小县，不觉八九年馀。 |
| 必有 | 必 / 有 | ok | 忽行至西洋大海，他想著海外必有神仙。 |
| 作筏 | 作 / 筏 | ok | 独自个依前作筏，又飘过西海，直至西牛贺洲地界。 |
| 登在 | 登 / 在 | ok | 他也不怕狼虫，不惧虎豹，登在山顶上观看。 |
| 排戟 | 排 / 戟 | ok | 千峰排戟，万仞开屏。 |
| 日映岚光 | 日映 / 岚光 | ok | 日映岚光轻锁翠，雨收黛色冷含青。 |
| 轻锁翠 | 轻锁 / 翠 | ok | 日映岚光轻锁翠，雨收黛色冷含青。 |
| 收黛色 | 收 / 黛色 | ok | 日映岚光轻锁翠，雨收黛色冷含青。 |
| 含青 | 含 / 青 | ok | 日映岚光轻锁翠，雨收黛色冷含青。 |
| 瘦藤缠 | 瘦藤 / 缠 | ok | 瘦藤缠老树，古渡界幽程。 |
| 古渡界 | 古渡 / 界 | ok | 瘦藤缠老树，古渡界幽程。 |
| 花瑞草 | 花 / 瑞草 | ok | 奇花瑞草，修竹乔松。 |
| 修竹乔 | 修竹 / 乔 | ok | 奇花瑞草，修竹乔松。 |
| 赛蓬 | 赛 / 蓬瀛 | fix|artifact|赛|蓬 | 奇花瑞草，四时不谢赛蓬瀛。 |
| 鸟啼 | 鸟 / 啼 | ok | 幽鸟啼声近，源泉响溜清。 |
| 声近 | 声 / 近 | ok | 幽鸟啼声近，源泉响溜清。 |
| 响溜清 | 响溜 / 清 | ok | 幽鸟啼声近，源泉响溜清。 |
| 高人隐 | 高人 / 隐 | ok | 起伏峦头龙脉好，必有高人隐姓名。 |
| 得林 | 得 / 林 | ok | 正观看间，忽闻得林深之处有人言语。 |
| 深之处 | 深 / 之处 | ok | 正观看间，忽闻得林深之处有人言语。 |
| 之声 | 歌唱 / 之声 | fix|artifact|之|声 | 急忙趋步，穿入林中，侧耳而听，原来是歌唱之声。 |
| 自陶情 | 自 / 陶情 | ok | 卖薪沽酒，狂笑自陶情。 |
| 枕松根 | 枕 / 松根 | ok | 苍迳秋高对月，枕松根、一觉天明。 |
| 认旧 | 认 / 旧林 | ok | 认旧林，登崖过岭，持斧断枯藤。 |
| 持斧断 | 持斧 / 断 | ok | 认旧林，登崖过岭，持斧断枯藤。 |
| 行歌市 | 行歌 / 市 | ok | 收来成一担，行歌市上，易米三升。 |
| 更无些 | 更无 / 些子 | ok | 更无些子争竞，时价平平。 |
| 非仙 | 非 / 仙 | ok | 相逢处，非仙即道，静坐讲《黄庭》。 |
| 举斧 | 举 / 斧 | ok | ”即忙跳入里面，仔细再看，乃是一个樵子，在那里举斧砍… |
| 新笋 | 新 / 笋 | ok | 头上戴箬笠，乃是新笋初脱之箨。 |
| 初脱 | 初 / 脱 | ok | 头上戴箬笠，乃是新笋初脱之箨。 |
| 之纱 | 之 / 纱 | ok | 身上穿布衣，乃是木绵撚就之纱。 |
| 系环 | 系 / 环 | ok | 腰间系环绦，乃是老蚕口吐之丝。 |
| 老蚕 | 老 / 蚕 | ok | 腰间系环绦，乃是老蚕口吐之丝。 |
| 之丝 | 之 / 丝 | ok | 腰间系环绦，乃是老蚕口吐之丝。 |
| 踏草履 | 踏 / 草履 | ok | 足下踏草履，乃是枯莎槎就之爽。 |
| 枯莎 | 枯 / 莎 | ok | 足下踏草履，乃是枯莎槎就之爽。 |
| 之爽 | 之 / 爽 | ok | 足下踏草履，乃是枯莎槎就之爽。 |
| 担挽火 | 担挽 / 火麻绳 | ok | 手执衠钢斧，担挽火麻绳。 |
| 扳松 | 扳 / 松 | ok | 扳松劈枯树，争似此樵能。 |
| 你说 | 你 / 说 | ok | ”猴王道：“我才来至林边，只听的你说：‘相逢处，非仙… |
| 词名做 | 词名 / 做 | fix|artifact|词|名做 | ”樵夫笑道：“实不瞒你说，这个词名做《满庭芳》，乃一… |
| 学得个 | 学得 / 个 | ok | 学得个不老之方，却不是好？ |
| 老之方 | 老 / 之|方 | ok | 学得个不老之方，却不是好？ |
| 母老 | 母 / 老 | ok | 如今母老，一发不敢抛离。 |
| 挑向 | 挑 / 向 | ok | 却又田园荒芜，衣食不足，只得斫两束柴薪，挑向市廛之间… |
| 几文钱 | 几 / 文钱 | ok | 却又田园荒芜，衣食不足，只得斫两束柴薪，挑向市廛之间… |
| 几升米 | 几 / 升米 | fix|artifact|几升|米 | 却又田园荒芜，衣食不足，只得斫两束柴薪，挑向市廛之间… |
| 自炊 | 自 / 炊 | ok | 却又田园荒芜，衣食不足，只得斫两束柴薪，挑向市廛之间… |
| 自造 | 自 / 造 | ok | 却又田园荒芜，衣食不足，只得斫两束柴薪，挑向市廛之间… |
| 但望 | 但 / 望 | ok | 但望你指与我那神仙住处，却好拜访去也。 |
| 不远 | 不 / 远 | ok | ”樵夫道：“不远，不远。 |
| 有座 | 有 / 座 | ok | 此山叫做灵台方寸山，山中有座斜月三星洞，那洞中有一个… |
| 那洞 | 那 / 洞 | ok | 此山叫做灵台方寸山，山中有座斜月三星洞，那洞中有一个… |
| 那条 | 那 / 条 | ok | 你顺那条小路儿，向南行七八里远近，即是他家了。 |
| 他家 | 他 / 家 | ok | 你顺那条小路儿，向南行七八里远近，即是他家了。 |
| 用手 | 用 / 手 | ok | ”猴王用手扯住樵夫道：“老兄，你便同我去去，若还得了… |
| 之恩 | 之 / 恩 | ok | ”猴王用手扯住樵夫道：“老兄，你便同我去去，若还得了… |
| 不省 | 不 / 省 | ok | ”樵夫道：“你这汉子甚不通变，我方才这般与你说了，你… |
| 我要 | 我 / 要 | ok | 我要斫柴，你自去，自去。 |
| 自去 | 自 / 去 | ok | 我要斫柴，你自去，自去。 |
| 深林 | 深 / 林 | ok | 出深林，找上路径，过一山坡，约有七八里远，果然望见一… |
| 真好 | 真 / 好 | ok | 挺身观看，真好去处！ |
| 散彩 | 散 / 彩 | ok | 烟霞散彩，日月摇光。 |
| 老柏 | 老 / 柏 | ok | 千株老柏，万节修篁。 |
| 带雨 | 带 / 雨 | ok | 千株老柏，带雨半空青冉冉； |
| 含烟 | 含 / 烟 | ok | 万节修篁，含烟一壑色苍苍。 |
| 一壑色 | 一壑 / 色 | fix|artifact|一|壑|色 | 万节修篁，含烟一壑色苍苍。 |
| 张翠藓长 | 张 / 翠藓|长 | fix|artifact|张|翠|藓|长 | 石崖突兀青苔润，悬壁高张翠藓长。 |
| 时闻 | 时 / 闻 | ok | 时闻仙鹤唳，每见凤凰翔。 |
| 声振 | 声 / 振 | ok | 仙鹤唳时，声振九皋霄汉远； |
| 翔起 | 翔 / 起 | ok | 凤凰翔起，翎毛五色彩云光。 |
| 云光 | 云 / 光 | ok | 凤凰翔起，翎毛五色彩云光。 |
| 随隐见 | 随 / 隐见 | ok | 玄猿白鹿随隐见，金狮玉象任行藏。 |
| 任行 | 任 / 行藏 | ok | 玄猿白鹿随隐见，金狮玉象任行藏。 |
| 立一 | 立 / 一 | ok | 忽回头，见崖头立一石碑，约有三丈馀高，八尺馀阔，上有… |
| 人果 | 人 / 果 | ok | 美猴王十分欢喜道：“此间人果是朴实，果有此山此洞。 |
| 果有 | 果 / 有 | ok | 美猴王十分欢喜道：“此间人果是朴实，果有此山此洞。 |
| 此山此 | 此山 / 此洞 | ok | 美猴王十分欢喜道：“此间人果是朴实，果有此山此洞。 |
| 见他 | 见 / 他 | ok | 但见他： |
| 身自别 | 身 / 自别 | ok | 貌和身自别，心与相俱空。 |
| 相俱空 | 相 / 俱空 | ok | 貌和身自别，心与相俱空。 |
| 年客 | 长年 / 客 | ok | 物外长年客，山中永寿童。 |
| 全不染 | 全 / 不染 | ok | 一尘全不染，甲子任翻腾。 |
| 出得门 | 出得 / 门 | ok | 那童子出得门来，高叫道：“甚么人在此搔扰？ |
| 下树来 | 下树 / 来 | ok | ”猴王扑的跳下树来，上前躬身道：“仙童，我是个访道学… |
| 可去 | 可 / 去 | ok | 说：‘外面有个修行的来了，可去接待接待。 |
| 衣端肃 | 整衣 / 端肃 | ok | 这猴王整衣端肃，随童子径入洞天深处观看：一层层深阁琼… |
| 没垢姿 | 没垢 / 姿 | ok | 大觉金仙没垢姿，西方妙相祖菩提。 |
| 相祖 | 相 / 祖 | ok | 大觉金仙没垢姿，西方妙相祖菩提。 |
| 任为 | 任 / 为之 | fix|artifact|任|为 | 空寂自然随变化，真如本性任为之。 |
| 天同寿 | 天 / 同寿 | ok | 与天同寿庄严体，历劫明心大法师。 |
| 大法师 | 大 / 法师 | ok | 与天同寿庄严体，历劫明心大法师。 |
| 神洲傲 | 神洲 / 傲 | ok | ”猴王道：“弟子乃东胜神洲傲来国花果山水帘洞人氏。 |
| 来国 | 来 / 国 | ok | ”猴王道：“弟子乃东胜神洲傲来国花果山水帘洞人氏。 |
| 他本 | 他 / 本 | ok | 他本是个撒诈捣虚之徒，那里修甚么道果！ |
| 登界游方 | 登界 / 游方 | ok | ”猴王叩头道：“弟子飘洋过海，登界游方，有十数个年头… |
| 又道 | 又 / 道 | ok | ”猴王又道：“我无性。 |
| 人若 | 人 / 若 | ok | 人若骂我，我也不恼； |
| 不恼 | 不 / 恼 | ok | 人若骂我，我也不恼； |
| 生的 | 生 / 的 | ok | ”祖师道：“既无父母，想是树上生的？ |
| 里长 | 里 / 长 | ok | ”猴王道：“我虽不是树上生，却是石里长的。 |
| 石破 | 石 / 破 | ok | 我只记得花果山上有一块仙石，其年石破，我便生也。 |
| 便生 | 便 / 生 | ok | 我只记得花果山上有一块仙石，其年石破，我便生也。 |
| 你姓 | 你 / 姓 | ok | 我与你就身上取个姓氏，意思教你姓‘猢’。 |
| 猢字 | 猢 / 字 | ok | 猢字去了个兽傍，乃是个古月。 |
| 古者 | 古 / 者 | ok | 古者，老也； |
| 老也 | 老 / 也 | ok | 古者，老也； |
| 月者 | 月 / 者 | ok | 月者，阴也。 |
| 倒好 | 倒 / 好 | ok | 老阴不能化育，教你姓‘狲’倒好。 |
| 子者 | 子 / 者 | ok | 子者，儿男也； |
| 系者 | 系 / 者 | ok | 系者。 |
| 正合 | 正 / 合 | ok | 婴细也，正合婴儿之本论。 |
| 之本论 | 之 / 本论 | ok | 婴细也，正合婴儿之本论。 |
| 有姓 | 有 / 姓 | ok | 万望师父慈悲，既然有姓，再乞赐个名字，却好呼唤。 |
| 乞赐个 | 乞赐 / 个 | ok | 万望师父慈悲，既然有姓，再乞赐个名字，却好呼唤。 |
| 辈之小徒 | 辈 / 之|小徒 | ok | ”祖师道：“我门中有十二个字，分派起名，到你乃第十辈… |
| 原无姓 | 原 / 无姓 | fix|artifact|原|无|姓 | 鸿濛初辟原无姓，打破顽空须悟空。 |
| 顽空须 | 顽空 / 须 | ok | 鸿濛初辟原无姓，打破顽空须悟空。 |

### word (339)

| token | verdict | confirm | sentence |
|---|---|---|---|
| 未分 | wèi fēn / "not yet separated" — of heaven and earth, before creation (classical, compositional 未+分) | fix|artifact|未|分 | 混沌未分天地乱，茫茫渺渺无人见。 |
| 从兹 | cóng zī / from this point on; thenceforth (classical) | ok | 自从盘古破鸿濛，开辟从兹清浊辨。 |
| 清浊 | qīng zhuó / the clear and the turbid — cosmic forces that separated to form heaven and earth | ok | 自从盘古破鸿濛，开辟从兹清浊辨。 |
| 覆载 | fù zài / to cover and sustain — heaven covers, earth bears up all things | ok | 覆载群生仰至仁，发明万物皆成善。 |
| 群生 | qún shēng / all living beings; the multitude of creatures | ok | 覆载群生仰至仁，发明万物皆成善。 |
| 欲知 | yù zhī / "if you wish to know..." — classical phrase introducing what follows | fix|artifact|欲|知 | 欲知造化会元功，须看《西游释厄传》。 |
| 须看 | xū kàn / "you should look at/read..." — classical recommendation phrase | fix|artifact|须|看 | 欲知造化会元功，须看《西游释厄传》。 |
| 盖闻 | gài wén / "it is said that..." — classical phrase opening an exposition | ok | 盖闻天地之数，有十二万九千六百岁为一元。 |
| 十二万 | shí èr wàn / 120,000 (numeral, compositional 十二+万) | ok | 盖闻天地之数，有十二万九千六百岁为一元。 |
| 九千 | jiǔ qiān / 9,000 (numeral) | ok | 盖闻天地之数，有十二万九千六百岁为一元。 |
| 而论 | ér lùn / "and so, considering" — classical connective in the pattern 就…而论 "as far as X goes" (cf. 就…而言) | fix|artifact|而|论 | 且就一日而论：子时得阳气，而丑则鸡鸣； |
| 阳气 | yáng qì / yang energy, the active/warming cosmic force said to arise at midnight (子时) in Chinese cosmology | ok | 且就一日而论：子时得阳气，而丑则鸡鸣； |
| 鸡鸣 | jī míng / cock-crow; the pre-dawn hour marked by roosters crowing | ok | 且就一日而论：子时得阳气，而丑则鸡鸣； |
| 食后 | shí hòu / after a meal, after eating | ok | 辰时食后，而巳则挨排； |
| 挨排 | āi pái / to line up in sequence, one after another (era spelling; cf. modern 排列) | ok | 辰时食后，而巳则挨排； |
| 日午 | rì wǔ / the sun at noon; midday | ok | 日午天中，而未则西蹉； |
| 譬于 | pì yú / to use as an analogy, in terms of (classical; cf. 譬如) | fix|artifact|譬|于 | 譬于大数，若到戌会之终，则天地昏曚而万物否矣。 |
| 故曰 | gù yuē / hence it is said; therefore called | ok | 再去五千四百岁，交亥会之初，则当黑暗，而两间人物俱无… |
| 贞下起元 | zhēn xià qǐ yuán / cyclical renewal — from the ending point (贞) a new beginning (元) arises; Yijing-derived cosmological term | ok | 又五千四百岁，亥会将终，贞下起元，近子之会，而复逐渐… |
| 而复 | ér fù / and then again; thereupon once more | fix|artifact|而|复 | 又五千四百岁，亥会将终，贞下起元，近子之会，而复逐渐… |
| 改移 | gǎiyí / to change, alter (classical; describes heaven's unchanging order) | ok | 邵康节曰：“冬至子之半，天心无改移。 |
| 子会 | zǐhuì / the "Zi" epoch — one of twelve ~10,800-year cosmic era-cycles in Shao Yong's numerological cosmology, tied to earthly branch zi | ok | 再五千四百岁，正当子会，轻清上腾，有日，有月，有星，… |
| 轻清 | qīngqīng / light and pure — the clear, buoyant element that rose up to form the heavens (cosmogonic term) | ok | 再五千四百岁，正当子会，轻清上腾，有日，有月，有星，… |
| 上腾 | shàngténg / to rise up, ascend | ok | 再五千四百岁，正当子会，轻清上腾，有日，有月，有星，… |
| 谓之 | wèizhī / to call it..., to be termed (classical construction: X谓之Y = "X is called Y") | ok | 日、月、星、辰，谓之四象。 |
| 至哉坤元 | zhì zāi kūn yuán / "Perfect indeed is the Origin of Kun!" — opening line of the Yijing's Kun hexagram Wenyan commentary, quoted to praise Earth's generative power | fix|word|zhì zāi kūn yuán|"Perfect indeed is the Origin of Kun!" — opening line of the Tuan (彖) commentary on the Yijing's Kun hexagram, quoted to praise Earth's generative power | 至哉坤元！ |
| 顺承 | shùnchéng / to receive/follow obediently, to accord submissively with (classical, from the Yijing) | ok | 万物资生，乃顺承天。 |
| 丑会 | chǒuhuì / the "Chou" epoch — second of the twelve cosmic era-cycles in Shao Yong's numerology | ok | 再五千四百岁，正当丑会，重浊下凝，有水，有火，有山，… |
| 重浊 | zhòngzhuó / heavy and turbid — the dense, impure element that sank to form the earth (cosmogonic term) | ok | 再五千四百岁，正当丑会，重浊下凝，有水，有火，有山，… |
| 地气 | dì qì / earth's qi/vapor rising to meet heaven's descending qi; classical cosmological pairing with 天气 | ok | 历曰：“天气下降，地气上升； |
| 寅会 | yín huì / the "Tiger" cosmic epoch, one of twelve ~10,800-year eras in Shao Yong's cosmological cycle, paired with 丑会 "Ox epoch" | ok | 再五千四百岁，正当寅会，生人，生兽，生禽，正谓天地人… |
| 治世 | zhì shì / to govern/rule the age; an era of good, orderly government | ok | 感盘古开辟，三皇治世，五帝定伦，世界之间，遂分为四大… |
| 定伦 | dìng lún / to establish the moral and social order (human relationships and hierarchy) | ok | 感盘古开辟，三皇治世，五帝定伦，世界之间，遂分为四大… |
| 名曰 | míng yuē / to be named/called (classical, introduces a name) | ok | 海外有一国土，名曰傲来国。 |
| 唤为 | huàn wéi / to be called/known as (classical) | ok | 国近大海，海中有一座名山，唤为花果山。 |
| 祖脉 | zǔ mài / ancestral mountain vein (geomantic root of a range's qi lineage) | ok | 此山乃十洲之祖脉，三岛之来龙，自开清浊而立，鸿濛判后… |
| 词赋 | cí fù / verse and rhapsody; classical poetic composition | ok | 有词赋为证。 |
| 为证 | wéi zhèng / as proof/evidence (formula introducing a verse as testimony) | ok | 有词赋为证。 |
| 赋曰 | fù yuē / the rhapsody reads: (formula introducing a quoted verse) | ok | 赋曰： |
| 势镇 | shì zhèn / its might dominates (classical descriptive verse phrase) | fix|artifact|势|镇 | 势镇汪洋，威宁瑶海。 |
| 银山 | yín shān / silver mountain(s) — poetic image for towering wave crests | ok | 势镇汪洋，潮涌银山鱼入穴； |
| 水火 | shuǐ huǒ / water and fire (paired classical term for the elements/extremes; fig. dire peril) | ok | 水火方隅高积上，东海之处耸崇巅。 |
| 方隅 | fāng yú / region, corner/quarter of a place (classical) | ok | 水火方隅高积上，东海之处耸崇巅。 |
| 之处 | zhī chù / the place/point where — classical suffix forming location nouns | ok | 水火方隅高积上，东海之处耸崇巅。 |
| 丹崖 | dān yá / red (cinnabar-colored) cliff | ok | 丹崖怪石，削壁奇峰。 |
| 怪石 | guài shí / strangely-shaped rock | ok | 丹崖怪石，削壁奇峰。 |
| 削壁 | xuē bì / sheer, knife-cut cliff face | ok | 丹崖怪石，削壁奇峰。 |
| 奇峰 | qí fēng / fantastic, oddly-shaped mountain peak | ok | 丹崖怪石，削壁奇峰。 |
| 彩凤 | cǎi fèng / multicolored phoenix | ok | 丹崖上，彩凤双鸣； |
| 峰头 | fēng tóu / mountaintop, summit | ok | 峰头时听锦鸡鸣，石窟每观龙出入。 |
| 仙狐 | xiān hú / fox spirit, immortal fox (mythical creature) | ok | 林中有寿鹿仙狐，树上有灵禽玄鹤。 |
| 灵禽 | líng qín / magical/auspicious bird, spirit bird | ok | 林中有寿鹿仙狐，树上有灵禽玄鹤。 |
| 玄鹤 | xuán hè / black crane (mythical/immortal bird, paired with 仙狐 "immortal fox") | fix|word|xuán hè|black crane (auspicious immortal bird; paired here with 灵禽, not 仙狐) | 林中有寿鹿仙狐，树上有灵禽玄鹤。 |
| 翠柏 | cuì bǎi / green cypress | ok | 瑶草奇花不谢，青松翠柏长春。 |
| 修竹 | xiū zhú / tall slender bamboo (literary) | ok | 仙桃常结果，修竹每留云。 |
| 藤萝 | téng luó / wisteria; climbing vines | ok | 一条涧壑藤萝密，四面原堤草色新。 |
| 原堤 | yuán dī / embankment on the plain (poetic) | ok | 一条涧壑藤萝密，四面原堤草色新。 |
| 草色 | cǎo sè / the color/hue of the grass | ok | 一条涧壑藤萝密，四面原堤草色新。 |
| 会处 | huì chù / confluence, place where waters meet | fix|artifact|会|处 | 正是百川会处擎天柱，万劫无移大地根。 |
| 擎天柱 | qíng tiān zhù / pillar propping up the sky (mythological support pillar) | ok | 正是百川会处擎天柱，万劫无移大地根。 |
| 无移 | wú yí / unmoving, immovable (classical/poetic) | fix|artifact|无|移 | 正是百川会处擎天柱，万劫无移大地根。 |
| 仙石 | xiān shí / immortal/enchanted stone (the magic stone of the story) | ok | 那座山正当顶上，有一块仙石。 |
| 围圆 | wéi yuán / circumference, girth | ok | 其石有三丈六尺五寸高，有二丈四尺围圆。 |
| 三百六十五 | sān bǎi liù shí wǔ / 365 (number) | ok | 三丈六尺五寸高，按周天三百六十五度； |
| 二十四 | èr shí sì / 24 (number) | ok | 二丈四尺围圆，按政历二十四气。 |
| 地秀 | dì xiù / the earth's fine essence (poetic, paired with 天真) | ok | 盖自开辟以来，每受天真地秀，日精月华，感之既久，遂有… |
| 日精 | rì jīng / essence of the sun (paired with 月华, moon's radiance); classical trope for cosmic vital forces that nourish and animate living things | ok | 盖自开辟以来，每受天真地秀，日精月华，感之既久，遂有… |
| 仙胞 | xiān bāo / "immortal embryo" — the mystical womb-like core inside the stone egg from which the Stone Monkey is born | ok | 内育仙胞，一日迸裂，产一石卵，似圆球样大。 |
| 俱备 | jù bèi / all present/fully formed — classical set phrase for a complete set of features | ok | 因见风，化作一个石猴，五官俱备，四肢皆全。 |
| 金光 | jīn guāng / golden light/radiance — stock image in classical fiction signaling something supernatural or divine | ok | 目运两道金光，射冲斗府。 |
| 慈仁者 | cí rén zhě / "the compassionate and benevolent one" — honorific epithet applied to a deity (here the Jade Emperor) | ok | 惊动高天上圣大慈仁者玉皇大天尊玄穹高上帝，驾座金阙云… |
| 驾座 | jià zuò / to sit enthroned in state — classical term for a deity/ruler taking his ceremonial seat | ok | 惊动高天上圣大慈仁者玉皇大天尊玄穹高上帝，驾座金阙云… |
| 仙卿 | xiān qīng / immortal court official; a minister among the celestial host | ok | 惊动高天上圣大慈仁者玉皇大天尊玄穹高上帝，驾座金阙云… |
| 即命 | jí mìng / thereupon ordered/commanded (classical set phrase) | fix|artifact|即|命 | 惊动高天上圣大慈仁者玉皇大天尊玄穹高上帝，驾座金阙云… |
| 观听 | guān tīng / to observe and listen; to investigate by sight and sound | ok | 须臾回报道：“臣奉旨观听金光之处，乃东胜神洲海东傲来… |
| 小国 | xiǎo guó / small country; minor state | ok | 须臾回报道：“臣奉旨观听金光之处，乃东胜神洲海东傲来… |
| 服饵 | fú ěr / to consume/ingest (food, medicine, elixirs); classical usage | ok | 如今服饵水食，金光将潜息矣。 |
| 水食 | shuǐ shí / food and drink; nourishment | ok | 如今服饵水食，金光将潜息矣。 |
| 潜息 | qián xī / to gradually subside/die down | ok | 如今服饵水食，金光将潜息矣。 |
| 山花 | shān huā / mountain flowers, wildflowers | ok | 那猴在山中，却会行走跳跃，食草木，饮涧泉，采山花，觅… |
| 狼虫 | láng chóng / wolves and tigers (虫 archaically = tiger); rapacious beasts | fix|word|láng chóng|wolves and other wild beasts (虫 = general term for creatures, not specifically tiger) | 与狼虫为伴，虎豹为群，獐鹿为友，猕猿为亲； |
| 为伴 | wéi bàn / to be companions (with) | ok | 与狼虫为伴，虎豹为群，獐鹿为友，猕猿为亲； |
| 虎豹 | hǔ bào / tigers and leopards | ok | 与狼虫为伴，虎豹为群，獐鹿为友，猕猿为亲； |
| 为群 | wéi qún / to flock/gather together | ok | 与狼虫为伴，虎豹为群，獐鹿为友，猕猿为亲； |
| 獐鹿 | zhāng lù / river deer and deer | ok | 与狼虫为伴，虎豹为群，獐鹿为友，猕猿为亲； |
| 为友 | wéi yǒu / to be friends (with) | ok | 与狼虫为伴，虎豹为群，獐鹿为友，猕猿为亲； |
| 猕猿 | mí yuán / macaques and apes/gibbons | ok | 与狼虫为伴，虎豹为群，獐鹿为友，猕猿为亲； |
| 为亲 | wéi qīn / to be kin (with) | ok | 与狼虫为伴，虎豹为群，獐鹿为友，猕猿为亲； |
| 夜宿 | yè sù / to lodge for the night | ok | 夜宿石崖之下，朝游峰洞之中。 |
| 石崖 | shí yá / stone cliff | ok | 夜宿石崖之下，朝游峰洞之中。 |
| 寒尽 | hán jìn / the cold season ends | ok | 真是：“山中无甲子，寒尽不知年。 |
| 群猴 | qún hóu / troop/band of monkeys | ok | 一朝天气炎热，与群猴避暑，都在松阴之下顽耍。 |
| 松阴 | sōng yīn / shade beneath pine trees (var. of 松荫) | ok | 一朝天气炎热，与群猴避暑，都在松阴之下顽耍。 |
| 顽耍 | wán shuǎ / to play, frolic (era spelling of modern 玩耍) | ok | 一朝天气炎热，与群猴避暑，都在松阴之下顽耍。 |
| 跳树 | tiào shù / to leap from tree to tree (of monkeys at play) | ok | 跳树攀枝，采花觅果； |
| 攀枝 | pān zhī / to climb from branch to branch | ok | 跳树攀枝，采花觅果； |
| 觅果 | mì guǒ / to search out fruit | ok | 跳树攀枝，采花觅果； |
| 么儿 | yāor (幺儿) / a children's pitch/toss game term (么/幺 = the "one" pip; here part of the game name 邷么儿) | ok | 抛弹子，邷么儿； |
| 沙窝 | shā wō / a sandy hollow or pit (for playing in sand) | ok | 跑沙窝，砌宝塔； |
| 𧈢 | (reading uncertain, cf. zhà) / rare/dialect character naming an insect, only attested combined as 𧈢蜡 (a small flying insect, cicada/lanternfly-like) | fix|word|bā|only in 𧈢蜡 (bā là), a grasshopper/locust (= 蚂蚱); the 巴 phonetic gives bā, not zhà | 赶蜻蜓，扑𧈢蜡； |
| 编草 | biān cǎo / to weave or plait with grass/straw | fix|artifact|编|草 | 扯葛藤，编草帓； |
| 帓 | mà / a woven cloth strip or headband (variant of 帕) | fix|word|mò|headband; a cloth band tied round the head (here 草帓, a plaited grass headband) | 扯葛藤，编草帓； |
| 古云 | gǔ yún / "as the ancients said" (fixed phrase introducing a proverb) | ok | 古云：“禽有禽言，兽有兽语。 |
| 兽语 | shòu yǔ / beast language, the speech of animals | ok | 古云：“禽有禽言，兽有兽语。 |
| 赶闲 | gǎn xián / to take advantage of free time; at leisure with nothing to do | ok | 我们今日赶闲无事，顺涧边往上溜头寻看源流，耍子去耶！ |
| 无事 | wú shì / to have nothing to do; free/idle | ok | 我们今日赶闲无事，顺涧边往上溜头寻看源流，耍子去耶！ |
| 寻看 | xún kàn / to search out and look for; go seeking | ok | 我们今日赶闲无事，顺涧边往上溜头寻看源流，耍子去耶！ |
| 飞泉 | fēi quán / cascading waterfall (poetic, lit. "flying spring") | ok | ”喊一声，都拖男挈女，呼弟呼兄，一齐跑来，顺涧爬山，… |
| 白虹 | bái hóng / white rainbow (poetic image for waterfall spray/mist) | ok | 一派白虹起，千寻雪浪飞。 |
| 翠微 | cuì wēi / verdant mountainside, green slopes (classical poetic term) | ok | 冷气分青嶂，馀流润翠微。 |
| 真似 | zhēn sì / truly like, just as if (classical verse comparison marker, cf. 恰似/好似) | fix|artifact|真|似 | 潺湲名瀑布，真似挂帘帷。 |
| 众猴 | zhòng hóu / the troop of monkeys, all the monkeys (collective term for the group) | ok | 众猴拍手称扬道：“好水，好水！ |
| 好水 | hǎo shuǐ / what wonderful water! (exclamation of praise) | fix|artifact|好|水 | 众猴拍手称扬道：“好水，好水！ |
| 远通 | yuǎn tōng / to extend/reach far, connect all the way to (a distant place) | fix|artifact|远|通 | 原来此处远通山脚之下，直接大海之波。 |
| 忽见 | hūjiàn / suddenly catch sight of, spot abruptly | ok | ”连呼了三声，忽见丛杂中跳出一个石猴，应声高叫道：“… |
| 丛杂 | cóngzá / thick and disorderly, tangled (of undergrowth) | ok | ”连呼了三声，忽见丛杂中跳出一个石猴，应声高叫道：“… |
| 芳名 | fāngmíng / one's (good) name — polite/literary term | ok | 今日芳名显，时来大运通。 |
| 时来 | shílái / when one's time/luck arrives (cf. idiom 时来运转) | ok | 今日芳名显，时来大运通。 |
| 蹲身 | dūnshēn / to crouch down, squat low | ok | 你看他瞑目蹲身，将身一纵，径跳入瀑布泉中，忽睁睛抬头… |
| 将身 | jiāngshēn / classical narrative formula marking the body as object before a verb of sudden movement ("with a motion of the body...") | ok | 你看他瞑目蹲身，将身一纵，径跳入瀑布泉中，忽睁睛抬头… |
| 跳入 | tiàorù / to jump/leap into | ok | 你看他瞑目蹲身，将身一纵，径跳入瀑布泉中，忽睁睛抬头… |
| 石窍 | shíqiào / a crevice or hole in rock | ok | 桥下之水，冲贯于石窍之间，倒挂流出去，遮闭了桥门。 |
| 遮闭 | zhēbì / to block off, screen from view | ok | 桥下之水，冲贯于石窍之间，倒挂流出去，遮闭了桥门。 |
| 桥门 | qiáomén / the archway/opening formed beneath the bridge | fix|word|qiáomén|the gateway/entrance at the bridge (the opening the bridge leads to, curtained by the falling water) | 桥下之水，冲贯于石窍之间，倒挂流出去，遮闭了桥门。 |
| 虚窗 | xū chuāng / bare lattice window of a secluded room; unadorned window | fix|word|xū chuāng|open/empty window; unshuttered window letting in light | 虚窗静室，滑凳板生花。 |
| 静室 | jìng shì / quiet chamber; secluded room for rest or meditation | ok | 虚窗静室，滑凳板生花。 |
| 生花 | shēng huā / to blossom; (of stone/wood) to form flower-like patterns | ok | 虚窗静室，滑凳板生花。 |
| 乳窟 | rǔ kū / stalactite grotto (cave hung with mineral "stone-milk" formations) | ok | 乳窟龙珠倚挂，萦回满地奇葩。 |
| 龙珠 | lóng zhū / "dragon pearl" — round stalactite/rock formation resembling the pearl dragons play with | ok | 乳窟龙珠倚挂，萦回满地奇葩。 |
| 满地 | mǎn dì / all over the ground; everywhere underfoot | ok | 乳窟龙珠倚挂，萦回满地奇葩。 |
| 傍崖 | bàng yá / next to/against the cliff | fix|artifact|傍|崖 | 锅灶傍崖存火迹，樽罍靠案见殽渣。 |
| 靠案 | kào àn / leaning against the (stone) table or counter | fix|artifact|靠|案 | 锅灶傍崖存火迹，樽罍靠案见殽渣。 |
| 殽 | yáo / (variant of 肴) meat dish; food, viands | ok | 锅灶傍崖存火迹，樽罍靠案见殽渣。 |
| 石座 | shí zuò / stone seat or pedestal | ok | 石座石床真可爱，石盆石碗更堪夸。 |
| 石床 | shí chuáng / stone bed or couch | ok | 石座石床真可爱，石盆石碗更堪夸。 |
| 石盆 | shí pén / stone basin | ok | 石座石床真可爱，石盆石碗更堪夸。 |
| 石碗 | shí wǎn / stone bowl | ok | 石座石床真可爱，石盆石碗更堪夸。 |
| 石碣 | shí jié / stone tablet/stele, often inscribed with text | ok | 只见正当中有一石碣，碣上有一行楷书大字，镌著“花果山… |
| 大字 | dà zì / large characters (esp. an inscription in big script) | ok | 只见正当中有一石碣，碣上有一行楷书大字，镌著“花果山… |
| 镌著 | juān zhe / engraved with, inscribed (modern form 镌着) | ok | 只见正当中有一石碣，碣上有一行楷书大字，镌著“花果山… |
| 石猿 | shí yuán / "stone monkey/ape" — epithet for the newborn Sun Wukong, born from a stone egg | ok | 石猿喜不自胜，急抽身往外便走，复瞑目蹲身，跳出水外，… |
| 怎见得 | zěn jiàn de / how can one tell?/how is it shown? (classical rhetorical phrase introducing proof) | ok | ”众猴道：“怎见得是个家当？ |
| 冲贯 | chōng guàn / to rush/gush through, pierce through | ok | ”石猴笑道：“这股水乃是桥下冲贯石桥，倒挂下来遮闭门… |
| 石桥 | shí qiáo / stone bridge | ok | ”石猴笑道：“这股水乃是桥下冲贯石桥，倒挂下来遮闭门… |
| 桥边 | qiáo biān / bridgeside, next to the bridge | ok | 桥边有花有树，乃是一座石房。 |
| 石房 | shí fáng / stone house/cottage | ok | 桥边有花有树，乃是一座石房。 |
| 房内 | fáng nèi / inside the house | ok | 房内有石窝、石灶、石碗、石盆、石床、石凳。 |
| 石窝 | shí wō / stone hollow/nook (a stone-carved furniture piece) | ok | 房内有石窝、石灶、石碗、石盆、石床、石凳。 |
| 石凳 | shí dèng / stone bench/stool | ok | 房内有石窝、石灶、石碗、石盆、石床、石凳。 |
| 安身之处 | ān shēn zhī chù / a place to settle down; a home/shelter | ok | 真个是我们安身之处。 |
| 容得 | róng de / able to hold/accommodate | ok | 里面且是宽阔，容得千百口老小。 |
| 存身 | cúnshēn / to find shelter/refuge for oneself, secure a place to stay | ok | 刮风有处躲，下雨好存身。 |
| 无惧 | wújù / to fear nothing, utterly fearless | ok | 霜雪全无惧，雷声永不闻。 |
| 松竹 | sōngzhú / pine and bamboo (paired as a classical symbol of steadfast integrity) | ok | 松竹年年秀，奇花日日新。 |
| 奇花 | qíhuā / a rare, exotic flower | ok | 松竹年年秀，奇花日日新。 |
| 伸头缩颈 | shēntóu-suōjǐng / to crane one's neck out then draw it back — to hover timidly, too scared to act | ok | 胆小的，一个个伸头缩颈，抓耳挠腮，大声叫喊，缠一会，… |
| 猴性 | hóuxìng / monkey nature; a restless, mischievous disposition (as attributed to monkeys) | ok | 跳过桥头，一个个抢盆夺碗，占灶争床，搬过来，移过去，… |
| 宁时 | níngshí / a moment of peace/calm | ok | 跳过桥头，一个个抢盆夺碗，占灶争床，搬过来，移过去，… |
| 人而无信 | rén ér wú xìn / (quoting the Analects) "if a person lacks trustworthiness..." — a person without good faith | ok | 石猿端坐上面道：“列位呵，‘人而无信，不知其可。 |
| 不知其可 | bù zhī qí kě / (quoting the Analects) "one doesn't know what he's fit for" — nothing can be done without trust | ok | 石猿端坐上面道：“列位呵，‘人而无信，不知其可。 |
| 稳睡 | wěnshuì / to sleep soundly and peacefully | ok | 我如今进来又出去，出去又进来，寻了这一个洞天与列位安… |
| 序齿 | xù chǐ / to rank/arrange in order of age (seniority) | ok | ”众猴听说，即拱伏无违，一个个序齿排班，朝上礼拜，都… |
| 字儿 | zì r / word/character (colloquial erhua form of 字) | fix|word|zìr|word/character (colloquial erhua form of 字) | 自此，石猿高登王位，将“石”字儿隐了，遂称“美猴王”… |
| 三阳交泰 | sān yáng jiāo tài / (idiom, cf. 三阳开泰) the three yang forces converge in harmony, an auspicious cosmic alignment marking new growth | ok | 三阳交泰产群生，仙石胞含日月精。 |
| 名姓 | míng xìng / name (inverted classical word order of 姓名) | ok | 借卵化猴完大道，假他名姓配丹成。 |
| 外合 | wài hé / outward conformity/union (paired with 内观 "inward contemplation"), a cultivation term | fix|artifact|外|合 | 内观不识因无相，外合明知作有形。 |
| 称王 | chēng wáng / to proclaim oneself king, to reign as king | ok | 历代人人皆属此，称王称圣任纵横。 |
| 君臣佐使 | jūn chén zuǒ shǐ / ruler, minister, aide, and courier — hierarchy of offices/roles (borrowed from the TCM prescription-hierarchy term) | fix|word|jūn chén zuǒ shǐ|sovereign, minister, assistant, envoy — the four ranks of a hierarchy of roles; also the classic TCM term for a prescription's principal and supporting herbs | 美猴王领一群猿猴、猕猴、马猴等，分派了君臣佐使。 |
| 合契 | hé qì / to be in perfect accord, matched like two halves of a tally | ok | 朝游花果山，暮宿水帘洞，合契同情，不入飞鸟之丛，不从… |
| 岁华 | suì huá / the passing years, the flow of time (classical, lit. "years' splendor") | ok | 秋收芋栗延时节，冬觅黄精度岁华。 |
| 何期 | hé qī / who would have expected; unexpectedly (classical interjection) | ok | 美猴王享乐天真，何期有三五百载。 |
| 忧恼 | yōu nǎo / to worry, be distressed | ok | 一日，与群猴喜宴之间，忽然忧恼，堕下泪来。 |
| 欢会 | huān huì / a joyful gathering, happy reunion | ok | 我等日日欢会，在仙山福地，古洞神洲，不伏麒麟辖，不伏… |
| 人王 | rén wáng / human ruler/king (as opposed to King Yama); mortal earthly sovereign | ok | ”猴王道：“今日虽不归人王法律，不惧禽兽威严，将来年… |
| 血衰 | xuè shuāi / blood/vitality declines (with old age) | ok | ”猴王道：“今日虽不归人王法律，不惧禽兽威严，将来年… |
| 管著 | guǎn zhe / to have charge/control over (著=modern 着, continuous aspect particle) | fix|artifact|管|著 | ”猴王道：“今日虽不归人王法律，不惧禽兽威严，将来年… |
| 枉生 | wǎng shēng / to have lived in vain, to waste one's life | ok | ”猴王道：“今日虽不归人王法律，不惧禽兽威严，将来年… |
| 掩面 | yǎn miàn / to cover one's face (in grief/weeping) | ok | ”众猴闻此言，一个个掩面悲啼，俱以无常为虑。 |
| 道心 | dào xīn / mind/heart set on spiritual cultivation, aspiration for the Way | ok | 只见那班部中，忽跳出一个通背猿猴，厉声高叫道：“大王… |
| 名色 | míng sè / kind, type, category (lit. "name and form") | ok | 如今五虫之内，惟有三等名色不伏阎王老子所管。 |
| 不生不灭 | bù shēng bù miè / Buddhist: unborn and undying, beyond birth and death | ok | ”猿猴道：“乃是佛与仙与神圣三者，躲过轮回，不生不灭… |
| 齐寿 | qí shòu / to share equal lifespan (with) | ok | ”猿猴道：“乃是佛与仙与神圣三者，躲过轮回，不生不灭… |
| 满心欢喜 | mǎn xīn huān xǐ / overjoyed, filled with delight | ok | ”猴王闻之，满心欢喜道：“我明日就辞汝等下山，云游海… |
| 不老 | bù lǎo / ageless, not growing old (as in 不老长生 "ageless and ever-living" — immortal) | ok | ”猴王闻之，满心欢喜道：“我明日就辞汝等下山，云游海… |
| 顿教 | dùn jiào / thereupon caused/made (classical causative: 顿 "suddenly/thereupon" + 教 used like 令/使 "to cause") | fix|artifact|顿|教 | 这句话，顿教跳出轮回网，致使齐天大圣成。 |
| 越岭 | yuè lǐng / to cross mountain ridges (paired with 登山 "climb mountains") | ok | 我等明日越岭登山，广寻些果品，大设筵宴送大王也。 |
| 香蕙 | xiāng huì / fragrant melilotus/orchid-grass; a sweet-smelling herb, used poetically for lush scenery | ok | 芝兰香蕙，瑶草奇花，般般件件，整整齐齐，摆开石凳石桌… |
| 摆开 | bǎi kāi / to lay out, spread out, arrange (dishes, seating, etc.) | ok | 芝兰香蕙，瑶草奇花，般般件件，整整齐齐，摆开石凳石桌… |
| 石桌 | shí zhuō / stone table | ok | 芝兰香蕙，瑶草奇花，般般件件，整整齐齐，摆开石凳石桌… |
| 红绽 | hóng zhàn / red and bursting/splitting open (of ripening fruit skin) | ok | 金丸珠弹，红绽黄肥。 |
| 黄肥 | huáng féi / yellow and plump (of ripening fruit) | ok | 金丸珠弹，红绽黄肥。 |
| 甘美 | gān měi / sweet and delicious, delightful in taste | ok | 金丸珠弹腊樱桃，色真甘美； |
| 碧实 | bì shí / jade-green, still-firm fruit (describes unripe-colored crabapples hanging on the branch) | fix|word|bì shí|jade-green fruit (poetic compound: 碧 "jade-green" + 实 "fruit"; parallels 缃苞 "pale-yellow husks" in the matching clause) | 林檎碧实连枝献，枇杷缃苞带叶擎。 |
| 兔头 | tù tóu / "rabbit-head" — shape-descriptor naming a pear cultivar (兔头梨/兔头梨子) | ok | 兔头梨子鸡心枣，消渴除烦更解酲。 |
| 鸡心 | jī xīn / "chicken-heart" — shape-descriptor naming a jujube cultivar (鸡心枣) | ok | 兔头梨子鸡心枣，消渴除烦更解酲。 |
| 除烦 | chú fán / to relieve vexation/restlessness (stock TCM collocation, cf. 除烦解渴) | ok | 兔头梨子鸡心枣，消渴除烦更解酲。 |
| 玉液琼浆 | yù yè qióng jiāng / nectar of the gods; delicious wine (lit. "jade liquid and carnelian syrup"; modern form 琼浆玉液) | ok | 香桃烂杏，美甘甘似玉液琼浆； |
| 红囊 | hóng náng / red flesh/pulp of a fruit (classical use of 囊 for the pulp sac, e.g. watermelon flesh) | ok | 红囊黑子熟西瓜，四瓣黄皮大柿子。 |
| 裂破 | liè pò / to split open, burst open (synonym-compound verb) | ok | 石榴裂破，丹砂粒现火晶珠； |
| 芋栗 | yù lì / taro and chestnuts (classical paired term for humble mountain food, cf. 松柏-type single-char noun pairs) | ok | 芋栗剖开，坚硬肉团金玛瑙。 |
| 剖开 | pōu kāi / to cut open, split open | ok | 芋栗剖开，坚硬肉团金玛瑙。 |
| 榛松 | zhēn sōng / hazelnuts and pine nuts (paired term for mountain nuts) | fix|artifact|榛|松 | 榛松榧奈满盘盛，橘蔗柑橙盈案摆。 |
| 橘蔗 | jú zhè / tangerines and sugarcane (paired term for fruit/produce) | fix|artifact|橘|蔗 | 榛松榧奈满盘盛，橘蔗柑橙盈案摆。 |
| 石锅 | shí guō / stone pot/cauldron (for cooking) | ok | 捣碎茯苓并薏苡，石锅微火漫炊羹。 |
| 漫炊 | màn chuī / to simmer/cook slowly over low heat | ok | 捣碎茯苓并薏苡，石锅微火漫炊羹。 |
| 奉酒 | fèng jiǔ / to offer/present wine respectfully (ritual toast) | ok | 群猴尊美猴王上坐，各依齿肩排于下边，一个个轮流上前奉… |
| 枯松 | kū sōng / withered/dead pine (tree or wood) | ok | 次日，美猴王早起，教：“小的们，替我折些枯松，编作筏… |
| 飘飘荡荡 | piāopiāo dàngdàng / drifting and swaying (AABB reduplication of 飘荡, to float/drift) | ok | ”果独自登筏，尽力撑开，飘飘荡荡，径向大海波中，趁天… |
| 地界 | dìjiè / territory; boundary of land, region | ok | ”果独自登筏，尽力撑开，飘飘荡荡，径向大海波中，趁天… |
| 这一去 | zhè yī qù / "and with this journey..." — narrative formula introducing a summary verse | ok | 这一去，正是那： |
| 天风 | tiānfēng / heavenly wind (lofty/celestial wind, poetic) | ok | 天产仙猴道行隆，离山驾筏趁天风。 |
| 飘洋过海 | piāoyáng guòhǎi / to sail across the seas (variant of standard 漂洋过海, travel overseas) | ok | 飘洋过海寻仙道，立志潜心建大功。 |
| 有分 | yǒufèn / to have a predestined share/lot (paired with 有缘, fated affinity) | ok | 有分有缘休俗愿，无忧无虑会元龙。 |
| 料应 | liàoyīng / presumably; it is expected that (classical adverb) | ok | 料应必遇知音者，说破源流万法通。 |
| 万法通 | wànfǎtōng / master of every method/dharma (cf. 万事通 "know-it-all"); one who comprehends all teachings | fix|artifact|万法|通 | 料应必遇知音者，说破源流万法通。 |
| 运至 | yùn zhì / classical: one's fortune/luck arrives (cf. modern idiom 时来运转); here "his luck turned" | ok | 也是他运至时来，自登木筏之后，连日东南风紧，将他送到… |
| 东南风 | dōngnán fēng / southeast wind (compositional, not a CEDICT headword) | ok | 也是他运至时来，自登木筏之后，连日东南风紧，将他送到… |
| 送到 | sòng dào / to deliver/send (someone/something) to a place | ok | 也是他运至时来，自登木筏之后，连日东南风紧，将他送到… |
| 𡤫 | lǎo (老) / likely a rare/corrupted variant rendering of 老 as in 老虎 "tiger"; "妆个老虎" = disguise oneself as a tiger to scare people | ok | 他走近前，弄个把戏，妆个𡤫虎，吓得那些人丢筐弃网，四… |
| 跑不动 | pǎo bu dòng / unable to run any further (potential-complement construction: 跑 + 不 + 动) | ok | 将那跑不动的拿住一个，剥了他的衣裳，也学人穿在身上。 |
| 穿州 | chuān zhōu / to pass through prefectures (first half of idiom 穿州过府, "travel far and wide") | ok | 摇摇摆摆，穿州过府，在市廛中学人礼，学人话。 |
| 过府 | guò fǔ / to pass through prefecture capitals (second half of idiom 穿州过府) | ok | 摇摇摆摆，穿州过府，在市廛中学人礼，学人话。 |
| 市廛 | shì chán / marketplace, shops (literary term) | ok | 摇摇摆摆，穿州过府，在市廛中学人礼，学人话。 |
| 人礼 | rén lǐ / human etiquette/manners (as opposed to animal behavior) | ok | 摇摇摆摆，穿州过府，在市廛中学人礼，学人话。 |
| 朝餐 | zhāo cān / to eat one's morning meal (classical; from idiom 朝餐夜宿, "travel ceaselessly") | ok | 朝餐夜宿，一心里访问佛、仙、神圣之道，觅个长生不老之… |
| 迟眠 | chí mián / to go to bed late (era phrasing, parallels 早起; modern equivalent 迟睡/晚睡) | ok | 早起迟眠不自由！ |
| 骑著 | qí zhe / riding (on); variant of 骑着 using classical 著 for 着 | fix|artifact|骑|著 | 骑著驴骡思骏马，官居宰相望王侯。 |
| 官居 | guān jū / to hold the rank/office of (an official post) | ok | 骑著驴骡思骏马，官居宰相望王侯。 |
| 参访 | cān fǎng / to seek out and inquire about (esp. a spiritual path or teacher) | ok | 猴王参访仙道，无缘得遇。 |
| 仙道 | xiān dào / the way/path of immortality; Daoist immortal arts | ok | 猴王参访仙道，无缘得遇。 |
| 得遇 | dé yù / to have the fortune of meeting/encountering (someone or something sought) | ok | 猴王参访仙道，无缘得遇。 |
| 行至 | xíng zhì / to travel/walk as far as, to arrive at | ok | 忽行至西洋大海，他想著海外必有神仙。 |
| 依前 | yī qián / as before, just as previously | ok | 独自个依前作筏，又飘过西海，直至西牛贺洲地界。 |
| 遍访 | biàn fǎng / to search/visit extensively, to seek out everywhere | ok | 登岸遍访多时，忽见一座高山秀丽，林麓幽深。 |
| 林麓 | lín lù / forested mountain foothills, wooded lower slopes | ok | 登岸遍访多时，忽见一座高山秀丽，林麓幽深。 |
| 果是 | guǒ shì / indeed was, sure enough it was (turned out to be) | ok | 果是好山： |
| 老树 | lǎoshù / old tree (transparent compound, poetic use) | fix|artifact|老|树 | 瘦藤缠老树，古渡界幽程。 |
| 幽程 | yōuchéng / secluded/quiet path or trail (poetic compound) | ok | 瘦藤缠老树，古渡界幽程。 |
| 谷壑 | gǔhè / valleys and ravines, mountain gullies | ok | 重重谷壑芝兰绕，处处巉崖苔藓生。 |
| 趋步 | qūbù / to hasten one's steps, hurry forward | ok | 急忙趋步，穿入林中，侧耳而听，原来是歌唱之声。 |
| 穿入 | chuānrù / to pass into, penetrate through (an area) | ok | 急忙趋步，穿入林中，侧耳而听，原来是歌唱之声。 |
| 歌曰 | gē yuē / (the) song goes/says — classical formula introducing sung verse | ok | 歌曰： |
| 观棋 | guān qí / watch a game of chess/Go (alludes to the immortals-at-chess tale) | ok | “观棋柯烂，伐木丁丁，云边谷口徐行。 |
| 柯烂 | kē làn / the axe-handle rots — allusion to losing track of time watching immortals play chess | ok | “观棋柯烂，伐木丁丁，云边谷口徐行。 |
| 云边 | yún biān / edge of the clouds, high mountain rim | ok | “观棋柯烂，伐木丁丁，云边谷口徐行。 |
| 卖薪 | mài xīn / to sell firewood | ok | 卖薪沽酒，狂笑自陶情。 |
| 沽酒 | gū jiǔ / to buy wine (classical usage) | ok | 卖薪沽酒，狂笑自陶情。 |
| 登崖 | dēng yá / to climb up a cliff | ok | 认旧林，登崖过岭，持斧断枯藤。 |
| 过岭 | guò lǐng / to cross over a mountain ridge | ok | 认旧林，登崖过岭，持斧断枯藤。 |
| 枯藤 | kū téng / withered/dry vine | ok | 认旧林，登崖过岭，持斧断枯藤。 |
| 收来 | shōu lái / to gather up, collect | ok | 收来成一担，行歌市上，易米三升。 |
| 易米 | yì mǐ / to trade for rice | ok | 收来成一担，行歌市上，易米三升。 |
| 争竞 | zhēng jìng / to contend, quarrel, compete (Song–Yuan vernacular) | ok | 更无些子争竞，时价平平。 |
| 巧算 | qiǎo suàn / clever scheming, cunning calculation | ok | 不会机谋巧算，没荣辱、恬淡延生。 |
| 延生 | yán shēng / to prolong life, live out one's years (classical/literary, cf. 延年益寿) | ok | 不会机谋巧算，没荣辱、恬淡延生。 |
| 听得 | tīng de / to hear, catch the sound of (vernacular verb+得, = modern 听到/听见) | ok | 美猴王听得此言，满心欢喜道：“神仙原来藏在这里！ |
| 砍柴 | kǎn chái / to chop/gather firewood | ok | ”即忙跳入里面，仔细再看，乃是一个樵子，在那里举斧砍… |
| 箬笠 | ruò lì / conical hat woven from ruò-bamboo leaves (rain/sun hat) | ok | 头上戴箬笠，乃是新笋初脱之箨。 |
| 木绵 | mù mián / cotton/kapok fiber (era variant of 木棉; 棉 is a later character) | ok | 身上穿布衣，乃是木绵撚就之纱。 |
| 口吐 | kǒu tǔ / to spew/emit from the mouth (set descriptive verb phrase) | fix|artifact|口|吐 | 腰间系环绦，乃是老蚕口吐之丝。 |
| 手执 | shǒu zhí / to hold in the hand (classical/vernacular, cf. modern 手持) | fix|artifact|手|执 | 手执衠钢斧，担挽火麻绳。 |
| 衠 | zhūn / pure, unadulterated (archaic character, synonym of 纯) | ok | 手执衠钢斧，担挽火麻绳。 |
| 钢斧 | gāng fǔ / steel axe | fix|artifact|钢|斧 | 手执衠钢斧，担挽火麻绳。 |
| 麻绳 | má shéng / hemp rope; cord of hemp fiber (here part of 火麻绳, "hemp rope") | ok | 手执衠钢斧，担挽火麻绳。 |
| 争似 | zhēng sì / (classical) how could it compare to; how is it like | ok | 扳松劈枯树，争似此樵能。 |
| 拙汉 | zhuō hàn / (self-deprecating) I, a clumsy/humble fellow; this unskilled man | ok | 我拙汉衣食不全，怎敢当‘神仙’二字？ |
| 不全 | bù quán / incomplete; insufficient; not adequate | ok | 我拙汉衣食不全，怎敢当‘神仙’二字？ |
| 敢当 | gǎn dāng / to dare accept (a title); to be worthy of (being called) | ok | 我拙汉衣食不全，怎敢当‘神仙’二字？ |
| 而何 | ér hé / (classical, after 非) then what else could it be? | ok | ’《黄庭》乃道德真言，非神仙而何？ |
| 笑道 | xiào dào / said with a smile (stock narrative tag in vernacular fiction) | ok | ”樵夫笑道：“实不瞒你说，这个词名做《满庭芳》，乃一… |
| 不瞒你说 | bù mán nǐ shuō / to tell you the truth; not to hide it from you | ok | ”樵夫笑道：“实不瞒你说，这个词名做《满庭芳》，乃一… |
| 词儿 | cír / song; verse; lyrics (colloquial diminutive of 词) | ok | 那神仙与我舍下相邻，他见我家事劳苦，日常烦恼，教我遇… |
| 解困 | jiě kùn / to relieve worry; to dispel distress | ok | 那神仙与我舍下相邻，他见我家事劳苦，日常烦恼，教我遇… |
| 你家 | nǐ jiā / (Yuan-Ming vernacular) you (dialectal pronoun, not "your family") | ok | ”猴王道：“你家既与神仙相邻，何不从他修行？ |
| 不敢 | bù gǎn / dare not; not venture to | ok | 如今母老，一发不敢抛离。 |
| 茶饭 | chá fàn / meals, food (cf. idiom 茶饭不思, "too troubled to eat") | ok | 却又田园荒芜，衣食不足，只得斫两束柴薪，挑向市廛之间… |
| 行孝 | xíng xiào / to act with filial devotion, to be a dutiful son/daughter | ok | 猴王道：“据你说起来，乃是一个行孝的君子，向后必有好… |
| 称名 | chēng míng / to be called/styled by the name of; to go by the name | ok | 此山叫做灵台方寸山，山中有座斜月三星洞，那洞中有一个… |
| 三四十 | sān sì shí / thirty or forty (approximate-number pattern, "X-Y-shí") | ok | 那祖师出去的徒弟，也不计其数，见今还有三四十人从他修… |
| 南行 | nán xíng / to travel south, to journey southward | ok | 你顺那条小路儿，向南行七八里远近，即是他家了。 |
| 相辞 | xiāng cí / to take leave of one another; say goodbye (classical/vernacular) | ok | 猴王听说，只得相辞。 |
| 但见 | dàn jiàn / "one sees that..." — formula introducing a set-piece description in vernacular fiction | ok | 但见： |
| 修篁 | xiū huáng / tall, slender bamboo (classical/poetic compound) | ok | 千株老柏，万节修篁。 |
| 瑶草 | yáo cǎo / fairy/jade grass; magical herb (poetic, Daoist paradise imagery) | ok | 门外奇花布锦，桥边瑶草喷香。 |
| 悬壁 | xuán bì / overhanging cliff; sheer precipice | ok | 石崖突兀青苔润，悬壁高张翠藓长。 |
| 玄猿 | xuán yuán / dark-furred gibbon/ape (classical poetic term) | ok | 玄猿白鹿随隐见，金狮玉象任行藏。 |
| 白鹿 | bái lù / white deer (auspicious/immortal creature in paradise imagery) | ok | 玄猿白鹿随隐见，金狮玉象任行藏。 |
| 金狮 | jīn shī / golden lion (mythical guardian beast, paradise imagery) | ok | 玄猿白鹿随隐见，金狮玉象任行藏。 |
| 玉象 | yù xiàng / jade elephant (mythical beast, paradise imagery) | ok | 玄猿白鹿随隐见，金狮玉象任行藏。 |
| 细观 | xì guān / to observe/examine closely | ok | 细观灵福地，真个赛天堂。 |
| 洞门 | dòng mén / the entrance/gate of a cave | ok | 又见那洞门紧闭，静悄悄杳无人迹。 |
| 崖头 | yá tóu / cliff top, edge of a cliff | ok | 忽回头，见崖头立一石碑，约有三丈馀高，八尺馀阔，上有… |
| 枝梢 | zhī shāo / tip/end of a tree branch | fix|artifact|松枝|梢头 | 且去跳上松枝梢头，摘松子吃了顽耍。 |
| 开处 | kāi chù / just as it opened (verb+处: "the moment X happened") | fix|artifact|开|处 | 少顷间，只听得呀的一声，洞门开处，里面走出一个仙童，… |
| 英伟 | yīng wěi / heroic and imposing in bearing | ok | 少顷间，只听得呀的一声，洞门开处，里面走出一个仙童，… |
| 清奇 | qīng qí / refined and extraordinary in appearance | ok | 少顷间，只听得呀的一声，洞门开处，里面走出一个仙童，… |
| 俗子 | sú zǐ / an ordinary/common (vulgar) person | ok | 少顷间，只听得呀的一声，洞门开处，里面走出一个仙童，… |
| 髽髻 | zhuā jì / hair twisted up into twin buns/topknots | fix|word|zhuā jì|hair gathered up into a knot/topknot | 髽髻双丝绾，宽袍两袖风。 |
| 双丝 | shuāng sī / a pair of silk cords/strands | fix|artifact|双|丝 | 髽髻双丝绾，宽袍两袖风。 |
| 宽袍 | kuānpáo / wide/loose robe (garment with ample sleeves) | fix|word|kuānpáo|loose, wide-cut robe | 髽髻双丝绾，宽袍两袖风。 |
| 我家 | wǒjiā / my (colloquial, lit. "my house's", used before a role/kinship term, e.g. 我家师父 "my master") | ok | ”童子道：“我家师父正才下榻，登坛讲道，还未说出原由… |
| 正才 | zhèngcái / just now, only just (era spelling; cf. modern 刚才/方才) | ok | ”童子道：“我家师父正才下榻，登坛讲道，还未说出原由… |
| 登坛 | dēngtán / to mount the platform/altar (to lecture or preach) | ok | ”童子道：“我家师父正才下榻，登坛讲道，还未说出原由… |
| 径入 | jìngrù / to go straight/directly in | ok | 这猴王整衣端肃，随童子径入洞天深处观看：一层层深阁琼… |
| 深阁 | shēngé / secluded inner chamber, deep pavilion | ok | 这猴王整衣端肃，随童子径入洞天深处观看：一层层深阁琼… |
| 琼楼 | qiónglóu / jade-like tower (poetic term for a magnificent building, esp. a celestial one) | ok | 这猴王整衣端肃，随童子径入洞天深处观看：一层层深阁琼… |
| 珠宫贝阙 | zhūgōng bèiquè / pearl palace with shell-inlaid gate-towers (poetic set phrase for a magnificent, fairy-tale palace) | ok | 这猴王整衣端肃，随童子径入洞天深处观看：一层层深阁琼… |
| 幽居 | yōujū / secluded dwelling, quiet retreat | ok | 这猴王整衣端肃，随童子径入洞天深处观看：一层层深阁琼… |
| 瑶台 | yáotái / jade terrace (poetic term for an immortal's dais/platform) | ok | 直至瑶台之下，见那菩提祖师端坐在台上，两边有三十个小… |
| 小仙 | xiǎoxiān / young/junior immortal (disciple attendant) | ok | 直至瑶台之下，见那菩提祖师端坐在台上，两边有三十个小… |
| 大觉 | dàjué / Great Enlightenment (Buddhist term for supreme awakening, used here as a reverent epithet) | ok | 大觉金仙没垢姿，西方妙相祖菩提。 |
| 金仙 | jīn xiān / "Golden Immortal" — honorific epithet for a fully enlightened being (here describing the Buddha/Patriarch-like figure) | ok | 大觉金仙没垢姿，西方妙相祖菩提。 |
| 全气 | quán qì / "wholly vital energy" — classical parallel construction paired with 全神 | fix|artifact|全|气 | 不生不灭三三行，全气全神万万慈。 |
| 全神 | quán shén / "wholly spirit," complete/undivided spiritual energy (cf. modern 全神贯注) | fix|artifact|全|神 | 不生不灭三三行，全气全神万万慈。 |
| 历劫 | lì jié / to pass through kalpas (eons) of hardship; endure trials across vast cosmic time | ok | 与天同寿庄严体，历劫明心大法师。 |
| 明心 | míng xīn / to illuminate/enlighten the mind (Buddhist term, cf. 明心见性) | ok | 与天同寿庄严体，历劫明心大法师。 |
| 只道 | zhǐ dào / just kept saying (classical/vernacular 道 used as "to say") | ok | 美猴王一见，倒身下拜，磕头不计其数，口中只道：“师父… |
| 志心 | zhì xīn / with utmost sincerity of heart; wholehearted devotion (Buddhist devotional term) | ok | 美猴王一见，倒身下拜，磕头不计其数，口中只道：“师父… |
| 朝礼 | cháo lǐ / to pay reverent homage/worship | ok | 美猴王一见，倒身下拜，磕头不计其数，口中只道：“师父… |
| 撒诈捣虚 | sā zhà dǎo xū / to lie, swindle, and bluff (idiom); a fraud and cheat | ok | 他本是个撒诈捣虚之徒，那里修甚么道果！ |
| 之徒 | zhī tú / person(s) of that (disparaging) sort — classical suffix | ok | 他本是个撒诈捣虚之徒，那里修甚么道果！ |
| 道果 | dào guǒ / fruits of spiritual cultivation; enlightenment attained through practice | ok | 他本是个撒诈捣虚之徒，那里修甚么道果！ |
| 之言 | zhī yán / the words/speech of... — classical possessive construction | fix|artifact|之|言 | ”猴王慌忙磕头不住道：“弟子是老实之言，决无虚诈。 |
| 决无 | jué wú / absolutely not, by no means (emphatic classical negation) | ok | ”猴王慌忙磕头不住道：“弟子是老实之言，决无虚诈。 |
| 访到 | fǎng dào / to find by searching, to track down after inquiring | fix|artifact|访|到 | ”猴王叩头道：“弟子飘洋过海，登界游方，有十数个年头… |
| 行来 | xíng lái / to travel along, to come traveling (over a journey/time) | fix|artifact|行|来 | 祖师道：“既是逐渐行来的也罢。 |
| 礼儿 | lǐ r / a small gift/gesture offered as an apology or courtesy | fix|word|lǐr|apology; courteous gesture (erhua form of 礼; 陪个礼儿 = to offer an apology) | 只是陪个礼儿就罢了。 |
| 其年 | qí nián / that year; in that (given) year — classical narrative marker | fix|artifact|其|年 | 我只记得花果山上有一块仙石，其年石破，我便生也。 |
| 跳起 | tiào qǐ / to jump up, to leap to one's feet | fix|artifact|跳|起 | ”猴王纵身跳起，拐呀拐的走了两遍。 |
| 古月 | gǔ yuè / "ancient"+"moon" — the two graphic components combined to form 胡 (hú), used in the riddle explaining the monkey's surname | ok | 猢字去了个兽傍，乃是个古月。 |
| 老阴 | lǎoyīn / "old yin" — one of the four Yijing configurations (老阳/老阴/少阳/少阴); here punning that 月 "moon" is aged yin and cannot generate life | ok | 老阴不能化育，教你姓‘狲’倒好。 |
| 化育 | huàyù / to engender and nurture; the creative, life-giving power of Heaven and Earth (classical, cf. Zhongyong) | ok | 老阴不能化育，教你姓‘狲’倒好。 |
| 儿男 | ér nán / sons; male offspring (classical, cf. modern 儿子) | ok | 子者，儿男也； |
| 婴细 | yīng xì / fine and delicate as an infant — fanciful gloss on 系 as a slender thread, punning toward "infant" | ok | 婴细也，正合婴儿之本论。 |
| 第十 | dì shí / tenth (ordinal 第 + 十) | ok | ”祖师道：“我门中有十二个字，分派起名，到你乃第十辈… |
| 排到 | pái dào / to reach/come around to (one's turn) in a sequence | ok | 排到你，正当‘悟’字。 |
| 自今 | zì jīn / from now on; henceforth (classical, cf. modern 从今) | ok | 自今就叫做孙悟空也。 |
| 初辟 | chū pì / newly cleft open — of primordial chaos first separating into heaven and earth (cf. 开辟) | ok | 鸿濛初辟原无姓，打破顽空须悟空。 |
| 下回分解 | xià huí fēnjiě / to be resolved/explained in the next chapter — stock phrase closing a chapter in vernacular fiction | ok | 毕竟不知向后修些甚么道果，且听下回分解。 |

