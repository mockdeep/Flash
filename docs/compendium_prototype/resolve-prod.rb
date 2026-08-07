# Entry-resolution dry run against a production export (read-only) — the
# production counterpart of resolve.rb, run 2026-08 over 31,312 zh fronts.
# Results are recorded in docs/compendium.md (Prototype findings).
#
# Local pg_dump 16 can't dump the Postgres 17 production DB, so this reads a
# CSV exported via a read-only query instead of ActiveRecord:
#
#   heroku pg:psql --app flash -c "\copy (SELECT ds.id AS set_id, ds.name AS
#     set_name, ds.user_id, i.id AS item_id, i.text, i.reading
#     FROM data_sets ds JOIN items i ON i.data_set_id = ds.id
#     WHERE ds.type = 'LanguageDataSet' AND ds.language = 'zh'
#       AND i.side = 'Front' ORDER BY ds.id, i.id)
#     TO 'tmp/compendium_prototype/prod_zh_fronts.csv' CSV HEADER"
#
# Run: ruby docs/compendium_prototype/resolve-prod.rb
#
# Beyond resolve.rb, this applies two migration-time front normalizations the
# production data demanded (each counted in the report):
#   - parenthesized traditional variants: "枪 (槍)" → "枪" (maps to
#     entries.script_variant; 3,914 rows)
#   - homograph superscripts: "过⁰" → "过" (artifact of the unique
#     (data_set_id, side, text) index; 19 rows)
require "csv"
require "json"

CSVS = "/home/fletch/Dropbox/projects/open_source/flash-csvs/mandarin"
FRONTS = File.expand_path("../../tmp/compendium_prototype/prod_zh_fronts.csv", __dir__)

def norm(pinyin)
  pinyin.to_s.unicode_normalize(:nfc).downcase.gsub(/[\s'’·]/, "")
end

# strip tone marks for the sandhi-tolerant fallback (不 bú vs bù etc.)
def toneless(pinyin)
  norm(pinyin).unicode_normalize(:nfd).gsub(/\p{Mn}/, "")
end

hsk = Hash.new { |h, k| h[k] = [] }
(1..7).each do |level|
  CSV.foreach(File.join(CSVS, "output/02-gloss/#{level}.csv"), headers: true) do |row|
    hsk[row["word"]] << row["pinyin"]
  end
end

cedict = JSON.parse(File.read(File.join(CSVS, "data/cedict.json")))
readings = ->(w) { (hsk.fetch(w, []) + (cedict[w] || []).map { |e| e["pinyin"] }).uniq }

buckets = Hash.new { |h, k| h[k] = [] }
set_meta = {}

norm_counts = Hash.new(0)
normalize_front = lambda do |text|
  t = text.strip
  stripped = t.gsub(/[⁰¹²³⁴⁵⁶⁷⁸⁹]/, "")
  norm_counts[:superscript] += 1 if stripped != t
  t = stripped
  stripped = t.sub(/\s*[(（][^)）]*[)）]\z/, "")
  norm_counts[:paren_variant] += 1 if stripped != t
  stripped.strip
end

CSV.foreach(FRONTS, headers: true) do |row|
  set_key = row["set_id"].to_i
  set_meta[set_key] = { name: row["set_name"], user_id: row["user_id"] }
  w = normalize_front.(row["text"].to_s)
  reading = row["reading"]
  cands = readings.(w)
  label =
    if cands.empty?
      "unresolved"
    elsif reading.nil? || reading.strip.empty?
      cands.map { |p| norm(p) }.uniq.size == 1 ? "no_reading_unambiguous" : "no_reading_ambiguous"
    elsif cands.any? { |p| norm(p) == norm(reading) }
      hsk.key?(w) ? "exact_hsk" : "exact_cedict"
    elsif cands.any? { |p| toneless(p) == toneless(reading) }
      "toneless_match"
    else
      "reading_mismatch"
    end
  buckets[[set_key, label]] << { text: w, reading: reading }
end

set_meta.keys.sort.each do |set_key|
  rows = buckets.select { |(s, _), _| s == set_key }
  total = rows.values.sum(&:size)
  meta = set_meta[set_key]
  puts "\n#{meta[:name]} (id #{set_key}, user #{meta[:user_id]}) — #{total} fronts"
  rows.sort_by { |(_, l), _| l }.each do |(_, label), items|
    puts "  #{label}: #{items.size}"
    next if %w[exact_hsk exact_cedict no_reading_unambiguous].include?(label)
    items.first(10).each do |i|
      puts "    #{i[:text]} (reading: #{i[:reading].inspect}) candidates: #{readings.(i[:text]).join(" / ")[0, 60]}"
    end
    puts "    ... +#{items.size - 10} more" if items.size > 10
  end
end

all = buckets.values.flatten
clean = buckets.select { |(_, l), _| %w[exact_hsk exact_cedict no_reading_unambiguous toneless_match].include?(l) }.values.flatten
puts "\nTOTAL: #{all.size} fronts, cleanly resolvable: #{clean.size} (#{(100.0 * clean.size / all.size).round(1)}%)"

label_totals = Hash.new(0)
buckets.each { |(_, l), items| label_totals[l] += items.size }
puts "By bucket:"
label_totals.sort_by { |_, n| -n }.each { |l, n| puts "  #{l}: #{n}" }
puts "Normalizations applied: #{norm_counts.inspect}"
