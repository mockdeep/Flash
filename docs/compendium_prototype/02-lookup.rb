# Join segmented words against the HSK deck (stand-in compendium lexicon) and
# full CC-CEDICT. Tokens missing from both get a verified pre-split pass first
# (deterministic re-segmentation of jieba merge artifacts); their counts fan out
# to the parts. Only what survives goes to the LLM. Statuses:
#   hsk    — word has existing card(s); candidate for the match step (phase A)
#   cedict — new word, CEDICT-grounded; contextual glossing (phase B)
#   miss   — not in CEDICT, not deterministically splittable; routing (phase C)
# Output: output/02-lookup/lookup.jsonl, output/02-lookup/splits.jsonl
require "csv"
require "json"
require "fileutils"

DIR  = __dir__
require_relative "texts"
SLUG = ARGV[0] || "kongyiji"
TEXTS.fetch(SLUG)
CSVS = "/home/fletch/Dropbox/projects/open_source/flash-csvs/mandarin"
IN   = File.join(OUTPUT_ROOT, "#{SLUG}/01-segment/words.jsonl")
OUT  = File.join(OUTPUT_ROOT, "#{SLUG}/02-lookup")
FileUtils.mkdir_p(OUT)

hsk = {}
(1..7).each do |level|
  CSV.foreach(File.join(CSVS, "output/02-gloss/#{level}.csv"), headers: true) do |row|
    (hsk[row["word"]] ||= []) << {
      level: level, pinyin: row["pinyin"], pos: row["pos"], back: row["back"],
    }
  end
end

cedict = JSON.parse(File.read(File.join(CSVS, "data/cedict.json")))

resolves = ->(w) { hsk.key?(w) || cedict.key?(w) }

# --- verified pre-split -------------------------------------------------------
# Applied ONLY to tokens absent from both lexicons, so dictionary-listed fused
# forms (不再, 为了, 马上, 一起) are never candidates. Each rule returns parts
# only when every non-number part resolves; otherwise the token falls through
# to LLM routing (phase C).
NUM_CHARS = "〇一二三四五六七八九十百千万几每两半多".chars.to_set
SUFFIXES  = %w[了 着 过 上 里 外 下 中 些 个 们 呢 么 罢].to_set

def number_run?(s) = s.chars.all? { |c| NUM_CHARS.include?(c) }

def try_split(w, resolves)
  chars = w.chars
  # reduplication: AA -> A
  if chars.size == 2 && chars[0] == chars[1] && resolves.(chars[0])
    return ["redup", [chars[0]]]
  end
  # A不A / V一V -> A (多不多, 看一看)
  if chars.size == 3 && chars[0] == chars[2] && %w[不 一].include?(chars[1]) && resolves.(chars[0])
    return ["a-not-a", [chars[0]]]
  end
  # leading number run + X (四文, 十九个, 二十多年)
  head = chars.take_while { |c| NUM_CHARS.include?(c) }.join
  if !head.empty? && head.length < w.length
    rest = w[head.length..]
    return ["number", [rest]] if resolves.(rest) # number run itself carries no card
  end
  # X + closed-class suffix (吊着, 脸上, 钱呢) — X must resolve
  if chars.size >= 2 && SUFFIXES.include?(chars.last)
    stem = w[0..-2]
    return ["suffix", [stem, chars.last]] if !number_run?(stem) && resolves.(stem) && resolves.(chars.last)
  end
  nil
end
# ------------------------------------------------------------------------------

require "set"
rows = File.foreach(IN).map { |l| JSON.parse(l) }
by_word = rows.to_h { |r| [r["word"], r] }

splits = []
rows.each do |r|
  next if resolves.(r["word"])
  rule, parts = try_split(r["word"], resolves)
  next unless rule
  splits << { "word" => r["word"], "rule" => rule, "parts" => parts, "count" => r["count"] }
  parts.each do |part|
    if (existing = by_word[part])
      existing["count"] += r["count"]
    else
      by_word[part] = r.merge("word" => part, "count" => r["count"])
    end
  end
  r["split"] = true
end

File.open(File.join(OUT, "splits.jsonl"), "w") do |f|
  splits.each { |s| f.puts JSON.generate(s) }
end

counts = Hash.new(0)
token_counts = Hash.new(0)
File.open(File.join(OUT, "lookup.jsonl"), "w") do |f|
  by_word.values.reject { |r| r["split"] }.sort_by { |r| r["seq"] }.each do |r|
    w = r["word"]
    status = hsk.key?(w) ? "hsk" : cedict.key?(w) ? "cedict" : "miss"
    counts[status] += 1
    token_counts[status] += r["count"]
    f.puts JSON.generate(r.merge(
      "status" => status,
      "hsk" => hsk.fetch(w, []),
      "cedict" => cedict.fetch(w, []),
    ))
  end
end
puts "pre-split: #{splits.size} tokens (#{splits.group_by { |s| s["rule"] }.map { |k, v| "#{k}: #{v.size}" }.join(", ")})"
puts "unique: #{counts.inspect}"
puts "tokens: #{token_counts.inspect}"
