# kongyiji — jieba vs LLM segmentation

Text: Lu Xun's short story 孔乙己 (1919, modern vernacular).

LLM run: 122 sentences, 122 passed exact concatenation check (0 needed a retry, 0 unrecovered).

| | jieba (raw) | LLM |
|---|---|---|
| Han tokens | 1382 | 1545 |
| unique words | 634 | 586 |
| lookup profile | hsk: 339 (53.5%), cedict: 158 (24.9%), miss: 137 (21.6%) | hsk: 382 (65.2%), cedict: 164 (28.0%), miss: 40 (6.8%) |
| shared unique words | 475 | |

## How the LLM handled jieba's known welds

Of 57 tokens the verified pre-split had to fix, the LLM never produced 50; it reproduced 7:

- 热热 (jieba pre-split as 热)
- 取下 (jieba pre-split as 取+下)
- 脸上 (jieba pre-split as 脸+上)
- 条条 (jieba pre-split as 条)
- 懒懒 (jieba pre-split as 懒)
- 两三天 (jieba pre-split as 天)
- 肩上 (jieba pre-split as 肩+上)

## jieba-only tokens (159)

**cedict (25)**: 一个 温酒 有水 羼 几天 一种 描红 引得 好喝 几次 一月 置辩 怎 半个 一层 嘴里 五指 起身 看一看 举人 向外 一句 几个 满手 不一会

**hsk (21)**: 帮 地 纸 大人 的话 添 何 读书 懒 过半 不屑 呀 一口气 直 丁 半夜 着火 半天 不成 要好 断

**miss (113)**: 四文 一碗 二十多年 每碗 要涨 十文 柜外 倘肯 多花 一文 一碟 出到 十二岁 咸亨 做点事 看着 舀出 看过 底里 放在 干不了 这事 总觉 一副 教人 几声 夹些 一部 十多年 上的 一到 柜里说 两碗 九文 睁大眼睛 污人 见你 吊着 涨红了脸 额上 …

## LLM-only tokens (111)

**cedict (31)**: 二十 倘 短衣帮 十二 舀 羼水 觉 话 污 额 绽 读书人 固穷 怎的 笼 茴 努 吃完 哉 十九 大半夜 穿上 下半天 站起来 不成样子 伸出 跌断 一会 说笑 自此 第二

**hsk (64)**: 个 四 年 每 涨 十 外 肯 碟 样 岁 底 放 几 天 干 种 副 声 夹 些 部 两 九 吊 脸 君子 引 穷 笔 次 记 月 半 层 嘴 头 配 刚 口 …

**miss (16)**: 慢慢地 咸亨酒店 描红纸 上大人孔乙己 添上 睁大 何家 钞钞 好喝懒做 偸窃 不屑置辩 对呀 直起 丁举人 忽然间 一九一九

