# Diff jieba segmentation (01 + 02's verified pre-split) against LLM
# segmentation (01b), classifying every unique word against the HSK deck and
# CC-CEDICT. Output: report-seg-<slug>.md
require "csv"
require "json"
require "set"

DIR = __dir__
require_relative "texts"
SLUG = ARGV[0] || "kongyiji"
DESC = TEXTS.fetch(SLUG)
CSVS = "/home/fletch/Dropbox/projects/open_source/flash-csvs/mandarin"
OUT  = File.join(DIR, "report-seg-#{SLUG}.md")

hsk = Set.new
(1..7).each do |level|
  CSV.foreach(File.join(CSVS, "output/02-gloss/#{level}.csv"), headers: true) { |row| hsk << row["word"] }
end
cedict = JSON.parse(File.read(File.join(CSVS, "data/cedict.json")))
status = ->(w) { hsk.include?(w) ? "hsk" : cedict.key?(w) ? "cedict" : "miss" }

load_words = ->(path) { File.foreach(path).map { |l| JSON.parse(l) }.to_h { |r| [r["word"], r] } }
jieba = load_words.(File.join(OUTPUT_ROOT, "#{SLUG}/01-segment/words.jsonl"))
llm   = load_words.(File.join(OUTPUT_ROOT, "#{SLUG}/01b-segment-llm/words.jsonl"))
splits = File.foreach(File.join(OUTPUT_ROOT, "#{SLUG}/02-lookup/splits.jsonl")).map { |l| JSON.parse(l) }
stats  = JSON.parse(File.read(File.join(OUTPUT_ROOT, "#{SLUG}/01b-segment-llm/stats.json")))

split_words = splits.to_h { |s| [s["word"], s] }
dist = ->(words) {
  by = words.keys.group_by(&status)
  %w[hsk cedict miss].map { |k| "#{k}: #{(by[k] || []).size} (#{(100.0 * (by[k] || []).size / words.size).round(1)}%)" }.join(", ")
}

jieba_only = jieba.keys - llm.keys
llm_only   = llm.keys - jieba.keys

io = File.open(OUT, "w")
io.puts "# #{SLUG} — jieba vs LLM segmentation"
io.puts
io.puts "Text: #{DESC}."
io.puts
io.puts "LLM run: #{stats["sentences"]} sentences, #{stats["verified"]} passed exact concatenation check " \
        "(#{stats["retried"]} needed a retry, #{stats["unrecovered"]} unrecovered)."
io.puts
io.puts "| | jieba (raw) | LLM |"
io.puts "|---|---|---|"
io.puts "| Han tokens | #{jieba.values.sum { |r| r["count"] }} | #{stats["han_tokens"]} |"
io.puts "| unique words | #{jieba.size} | #{llm.size} |"
io.puts "| lookup profile | #{dist.(jieba)} | #{dist.(llm)} |"
io.puts "| shared unique words | #{(jieba.keys & llm.keys).size} | |"
io.puts
io.puts "## How the LLM handled jieba's known welds"
io.puts
resolved = split_words.keys.reject { |w| llm.key?(w) }
io.puts "Of #{split_words.size} tokens the verified pre-split had to fix, the LLM never produced " \
        "#{resolved.size}; it reproduced #{split_words.size - resolved.size}:"
io.puts
(split_words.keys & llm.keys).each { |w| io.puts "- #{w} (jieba pre-split as #{split_words[w]["parts"].join("+")})" }
io.puts
io.puts "## jieba-only tokens (#{jieba_only.size})"
io.puts
jieba_only.group_by(&status).sort.each do |st, ws|
  io.puts "**#{st} (#{ws.size})**: #{ws.first(40).join(" ")}#{ws.size > 40 ? " …" : ""}"
  io.puts
end
io.puts "## LLM-only tokens (#{llm_only.size})"
io.puts
llm_only.group_by(&status).sort.each do |st, ws|
  io.puts "**#{st} (#{ws.size})**: #{ws.first(40).join(" ")}#{ws.size > 40 ? " …" : ""}"
  io.puts
end
io.close
puts "wrote #{OUT}"
