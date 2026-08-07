# Sense-selection accuracy (match step, Sonnet single pass)

Ground truth: multi-level HSK headwords with distinct glosses; each level's
judge-verified example sentence should select that level's sense.

- Overall: 120/124 (96.8%)
- Reading at stake (homograph resolution): 86/90 (95.6%)
- Same reading (pure sense split): 34/34 (100.0%)
- Answered 0 (no sense fits): 0

## Misses (4)

- **转** expected (1), chose (2) — senses: zhuǎn: to turn / zhuàn: to revolve — 他转了转他的眼睛
- **挑** expected (2), chose (1) — senses: tiāo: to choose; to pick; to carry on a shoulder pole / tiǎo: to poke; to incite — 他喜欢挑事。
- **炸** expected (1), chose (2) — senses: zhá: to deep fry / zhà: to burst; to explode — 我整个晚上梦见的都是炸红薯。
- **圈** expected (2), chose (3) — senses: quān: circle; (fig.) community; to encircle; to mark with a circle / juān: to confine / juàn: livestock pen — 我们把牲畜圈在院子里。
