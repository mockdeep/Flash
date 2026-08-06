# Compendium content-pipeline prototype

Throwaway research scripts behind the "Prototype findings (2026-08)" section of
[../compendium.md](../compendium.md). Not app code; quality bar is
prove-the-design, not ship.

Pipeline (per text; slug from `texts.rb` as ARGV, default `kongyiji`):

```
ruby 01-segment.rb <slug>    # cppjieba + flash-csvs HSK user dict
ruby 02-lookup.rb <slug>     # HSK/CEDICT lookup + verified pre-split of misses
ruby 03-gloss.rb <slug>      # Sonnet: match step / contextual gloss / miss routing
ruby 03b-confirm.rb <slug>   # Opus confirm tier over every Sonnet proposal
ruby 04-report.rb <slug>     # -> report-<slug>.md (committed here)
bin/rails runner docs/compendium_prototype/resolve.rb   # migration entry-resolution dry run (read-only)
```

- Reference data comes from the flash-csvs repo (`../../../flash-csvs/mandarin`):
  cedict.json, the jieba user dict, and the HSK 02-gloss CSVs.
- 03/03b shell out to the `claude` CLI — run them with the sandbox off. Both are
  resumable; re-run to fill in unparsed batches.
- Intermediates regenerate into `tmp/compendium_prototype/output/` and are not
  committed; the two `report-*.md` files are the preserved results.
- Texts are public domain, from Chinese Wikisource (simplified via variant
  conversion).
