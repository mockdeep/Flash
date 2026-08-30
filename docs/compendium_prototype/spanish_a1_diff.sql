-- Why the three "Spanish A1 Vocab" forks (22, 23, 30) fail fork_compare.sql's
-- front gate, and what an article-aware relink has to handle. Read-only.
--
--   heroku pg:psql --app flash -f docs/compendium_prototype/spanish_a1_diff.sql
--
-- Result (2026-08-30): the forks hold the same 482 words as seed list 9 in an
-- older presentation — bare nouns where seed now writes "el pelo" (and
-- "el/la cantante" for common gender), topical `category` values where seed
-- writes parts of speech — plus a stray "centro" beside "el centro". Stripping
-- one leading article from the seed side leaves 9 fork-only and 8 seed-only
-- rows, and every one of those is either a common-gender "el/la X" or a front
-- the fork had already articled. See phase 4's pre-rung in ../compendium.md.

\echo '== fronts only in fork 22 (sample) =='
SELECT i.text, i.category
FROM items i
WHERE i.word_list_id = 22 AND i.side = 'Front'
  AND NOT EXISTS (SELECT 1 FROM items j
                    WHERE j.word_list_id = 9 AND j.side = 'Front'
                      AND j.text = i.text)
ORDER BY i.id LIMIT 25;

\echo '== fronts only in seed 9 (sample) =='
SELECT i.text, i.category
FROM items i
WHERE i.word_list_id = 9 AND i.side = 'Front'
  AND NOT EXISTS (SELECT 1 FROM items j
                    WHERE j.word_list_id = 22 AND j.side = 'Front'
                      AND j.text = i.text)
ORDER BY i.id LIMIT 25;

\echo '== what survives stripping one leading article from the seed side =='
WITH s AS (
  SELECT regexp_replace(lower(text), '^(el|la|los|las|un|una) ', '') AS t
  FROM items WHERE word_list_id = 9 AND side = 'Front'
), f AS (
  SELECT lower(text) AS t
  FROM items WHERE word_list_id = 22 AND side = 'Front'
)
SELECT 'fork only' AS side, t FROM f WHERE NOT EXISTS (SELECT 1 FROM s WHERE s.t = f.t)
UNION ALL
SELECT 'seed only', t FROM s WHERE NOT EXISTS (SELECT 1 FROM f WHERE f.t = s.t)
ORDER BY 1, 2;

\echo '== the three forks are identical to each other =='
SELECT
  (SELECT count(*) FROM items a
     WHERE a.word_list_id = 22 AND a.side = 'Front'
       AND NOT EXISTS (SELECT 1 FROM items b
                         WHERE b.word_list_id = 23 AND b.side = 'Front'
                           AND b.text = a.text)) AS l22_not_in_l23,
  (SELECT count(*) FROM items a
     WHERE a.word_list_id = 22 AND a.side = 'Front'
       AND NOT EXISTS (SELECT 1 FROM items b
                         WHERE b.word_list_id = 30 AND b.side = 'Front'
                           AND b.text = a.text)) AS l22_not_in_l30;

\echo '== decks affected, and whether category decoys matter to them =='
SELECT d.id, d.user_id, d.word_list_id, d.distractor_pool, d.level,
       (SELECT coalesce(sum(c.view_count), 0) FROM cards c WHERE c.deck_id = d.id) AS views
FROM decks d WHERE d.word_list_id IN (9, 22, 23, 30) ORDER BY d.word_list_id;

\echo '== seed category values (topical -> part of speech) =='
SELECT category, count(*) FROM items
WHERE word_list_id = 9 AND side = 'Front' GROUP BY category ORDER BY 2 DESC LIMIT 10;
