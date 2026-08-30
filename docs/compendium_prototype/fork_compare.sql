-- Fork-collapse dry run (read-only): compares every non-seed word_list against
-- the seed-account list of the same name + language, to decide which forks can
-- be relinked with no visible change. Behind the four groups in phase 4's
-- "Collapse the legacy forks" pre-rung; results as of 2026-08-30 are quoted in
-- ../compendium.md.
--
-- Run against production:
--   heroku pg:psql --app flash -f docs/compendium_prototype/fork_compare.sql
--
-- Columns, and the gate they feed:
--   word_only_fork / word_only_seed  fronts present on one side only (by text)
--   reading_differs                  shared fronts whose reading disagrees
--   gloss_differs                    shared fronts whose paired back texts
--                                    disagree — what the card shows on reveal
--   meta_differs                     example / paired_example / category —
--                                    report-only, not a gate
-- All zeros across the first four = a lossless relink. A null seed_id means no
-- seed list carries that name, i.e. residue rather than a fork.
WITH fork AS (
  SELECT id, user_id, name, language FROM word_lists WHERE user_id <> 1
), seed AS (
  SELECT id, name, language FROM word_lists WHERE user_id = 1
)
SELECT
  f.id   AS fork_id,
  f.user_id,
  f.language AS lang,
  f.name,
  (SELECT count(*) FROM items i
     WHERE i.word_list_id = f.id AND i.side = 'Front') AS fork_fronts,
  s.id   AS seed_id,
  (SELECT count(*) FROM items i
     WHERE i.word_list_id = s.id AND i.side = 'Front') AS seed_fronts,
  (SELECT count(*) FROM items i
     WHERE i.word_list_id = f.id AND i.side = 'Front'
       AND NOT EXISTS (SELECT 1 FROM items j
                         WHERE j.word_list_id = s.id AND j.side = 'Front'
                           AND j.text = i.text)) AS word_only_fork,
  (SELECT count(*) FROM items i
     WHERE i.word_list_id = s.id AND i.side = 'Front'
       AND NOT EXISTS (SELECT 1 FROM items j
                         WHERE j.word_list_id = f.id AND j.side = 'Front'
                           AND j.text = i.text)) AS word_only_seed,
  (SELECT count(*) FROM items i
     JOIN items j ON j.word_list_id = s.id AND j.side = 'Front'
                 AND j.text = i.text
     WHERE i.word_list_id = f.id AND i.side = 'Front'
       AND i.reading IS DISTINCT FROM j.reading) AS reading_differs,
  (SELECT count(*) FROM items i
     JOIN items j ON j.word_list_id = s.id AND j.side = 'Front'
                 AND j.text = i.text
     WHERE i.word_list_id = f.id AND i.side = 'Front'
       AND (SELECT array_agg(b.text ORDER BY b.text)
              FROM pairings p JOIN items b ON b.id = p.paired_item_id
              WHERE p.item_id = i.id)
        IS DISTINCT FROM
           (SELECT array_agg(b.text ORDER BY b.text)
              FROM pairings p JOIN items b ON b.id = p.paired_item_id
              WHERE p.item_id = j.id)) AS gloss_differs,
  (SELECT count(*) FROM items i
     JOIN items j ON j.word_list_id = s.id AND j.side = 'Front'
                 AND j.text = i.text
     WHERE i.word_list_id = f.id AND i.side = 'Front'
       AND (i.example IS DISTINCT FROM j.example
            OR i.paired_example IS DISTINCT FROM j.paired_example
            OR i.category IS DISTINCT FROM j.category)) AS meta_differs
FROM fork f
LEFT JOIN seed s ON s.name = f.name AND s.language = f.language
ORDER BY f.language, f.name, f.id;
