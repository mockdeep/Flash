# xiyouji1 — jieba vs LLM segmentation

Text: chapter 1 of 西游记 (Journey to the West, Ming dynasty c. 1592; vernacular novel prose mixed with classical verse).

LLM run: 395 sentences, 395 passed exact concatenation check (0 needed a retry, 0 unrecovered).

| | jieba (raw) | LLM |
|---|---|---|
| Han tokens | 3309 | 4107 |
| unique words | 1952 | 1773 |
| lookup profile | hsk: 561 (28.7%), cedict: 562 (28.8%), miss: 829 (42.5%) | hsk: 796 (44.9%), cedict: 688 (38.8%), miss: 289 (16.3%) |
| shared unique words | 1188 | |

## How the LLM handled jieba's known welds

Of 110 tokens the verified pre-split had to fix, the LLM never produced 87; it reproduced 23:

- 渺渺 (jieba pre-split as 渺)
- 两间 (jieba pre-split as 间)
- 三才 (jieba pre-split as 才)
- 三岛 (jieba pre-split as 岛)
- 林中 (jieba pre-split as 林+中)
- 树上 (jieba pre-split as 树+上)
- 万劫 (jieba pre-split as 劫)
- 九宫 (jieba pre-split as 宫)
- 山上 (jieba pre-split as 山+上)
- 山中 (jieba pre-split as 山+中)
- 一朝 (jieba pre-split as 朝)
- 片片 (jieba pre-split as 片)
- 百花 (jieba pre-split as 花)
- 五虫 (jieba pre-split as 虫)
- 三者 (jieba pre-split as 者)
- 躲过 (jieba pre-split as 躲+过)
- 般般 (jieba pre-split as 般)
- 波中 (jieba pre-split as 波+中)
- 甚么 (jieba pre-split as 甚+么)
- 二则 (jieba pre-split as 则)
- 九皋 (jieba pre-split as 皋)
- 口中 (jieba pre-split as 口+中)
- 万望 (jieba pre-split as 望)

## jieba-only tokens (764)

**cedict (89)**: 诗曰 一元 十二支 不通 日落 曚 乾 有水 生人 洲 东胜 赡 芦洲 鸿 威宁 潮涌 不谢 一块 九窍 一个 就学 玉皇 上帝 宝殿 焰 风化 所生 采花 潺 湲 无水 板 樽 罍 往外 问道 永不 得来 秋收 老子 …

**hsk (35)**: 昏 人物 物资 人生 北 天上 出门 蜡 不断 明明 倚 渣 一行 得力 马 同情 精度 阎王 背 件 拿 中学 心里 忙 不当 的话 斜 得了 变 色彩 就是 妙 重大 个性 个子

**miss (640)**: 未分 破鸿 濛 仰至仁 成善 欲知 会元功 须看 西游 释厄传 盖闻 之数 十二万 九千 百岁 乃子 每会 一万八 一日 而论 而卯 食后 日午 天中 未则西 而人定 譬于 到戌会 之终 否矣 五千四百岁 交亥会 故曰 近子 之会 而复 子之半 一阳 初动处 未生 …

## LLM-only tokens (585)

**cedict (215)**: 仁 欲 会元 论 子时 譬 否 阳 到此 始 资 承 谓 辟 历 伦 南赡部洲 唤 赋 势 威 宁 穴 波 蜃 渊 崇 巅 锦鸡 观 寿 狐 谢 涧壑 色 丈 窍 意 育 目 …

**hsk (270)**: 分 破 仰 善 功 须 盖 数 岁 支 通 落 交 故 近 半 动 地 群 清 爽 四 部 书 单 国 自 立 判 证 镇 潮 鱼 入 翻 离 积 耸 双 鸣 …

**miss (100)**: 鸿濛 西游释厄传 十二万九千六百 一万八百 昏曚 五千四百 乾元 坤元 天地人 东胜神洲 西牛贺洲 北俱芦洲 十洲 来龙 雪浪 政历 石卵 斗府 高天上圣大慈仁者玉皇大天尊玄穹高上帝 金阙云宫灵霄宝殿 焰焰 傲来 𧈢蜡 草帓 往上 潺湲 睁睛 那里边 明明朗朗 翠藓 凳板 倚挂 火迹 殽渣 千百 千岁大王 无相 马猴 合契同情 阎王老子 …

