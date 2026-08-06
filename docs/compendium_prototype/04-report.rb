# Assemble the chapter report from the gloss verdicts, pre-split log, and
# confirm-tier outcomes. Output: report.md
require "json"

DIR     = __dir__
require_relative "texts"
SLUG    = ARGV[0] || "kongyiji"
DESC    = TEXTS.fetch(SLUG)
IN      = File.join(OUTPUT_ROOT, "#{SLUG}/03-gloss/gloss.jsonl")
SPLITS  = File.join(OUTPUT_ROOT, "#{SLUG}/02-lookup/splits.jsonl")
CONFIRM = File.join(OUTPUT_ROOT, "#{SLUG}/03b-confirm/confirm.jsonl")
OUT     = File.join(DIR, "report-#{SLUG}.md")

rows = File.foreach(IN).map { |l| JSON.parse(l) }.sort_by { |r| r["seq"] }
splits = File.exist?(SPLITS) ? File.foreach(SPLITS).map { |l| JSON.parse(l) } : []
confirm = File.exist?(CONFIRM) ? File.foreach(CONFIRM).to_h { |l| r = JSON.parse(l); [r["word"], r["confirm"]] } : {}
segmented = File.foreach(File.join(OUTPUT_ROOT, "#{SLUG}/01-segment/words.jsonl")).map { |l| JSON.parse(l) }
tokens_total = segmented.sum { |r| r["count"] }

def sent(r, len = 26)
  s = r["sentence"]
  s.length > len ? "#{s[0, len]}…" : s
end

def parts(r) = r["verdict"].split("|", 3)

def confirm_cell(c)
  return "—" unless c
  c == "ok" ? "ok" : c
end

a = rows.select { |r| r["phase"] == "A" }
b = rows.select { |r| r["phase"] == "B" }
c = rows.select { |r| r["phase"] == "C" }

a_covered, a_new = a.partition { |r| parts(r)[0] == "covered" }
a_confirmed = a_new.select { |r| confirm[r["word"]] == "ok" }
a_rejected  = a_new.select { |r| confirm[r["word"]]&.start_with?("reject") }
b_by = b.group_by { |r| parts(r)[0] }
c_by = c.group_by { |r| parts(r)[0] }

hsk_tokens    = a.sum { |r| r["count"] }
cedict_tokens = b.sum { |r| r["count"] }
miss_tokens   = c.sum { |r| r["count"] }
split_tokens  = splits.sum { |s| s["count"] }

fixes = ->(list) { list.count { |r| confirm[r["word"]]&.start_with?("fix") } }

min_level = ->(r) { r["hsk"].map { |h| h["level"] }.min }
by_level = a.group_by(&min_level).sort

io = File.open(OUT, "w")
io.puts "# #{SLUG} — compendium pipeline prototype report"
io.puts
io.puts "Text: #{DESC}, simplified, #{tokens_total} Han tokens, #{rows.size} studyable words."
io.puts "Lexicon stand-in: HSK 1–7 deck (flash-csvs). Sonnet proposes, Opus confirms."
io.puts
io.puts "## Coverage"
io.puts
io.puts "| bucket | unique words | tokens | token share |"
io.puts "|---|---|---|---|"
io.puts "| in lexicon (HSK) | #{a.size} | #{hsk_tokens} | #{(100.0 * hsk_tokens / tokens_total).round(1)}% |"
io.puts "| new, CEDICT-grounded | #{b.size} | #{cedict_tokens} | #{(100.0 * cedict_tokens / tokens_total).round(1)}% |"
io.puts "| not in CEDICT | #{c.size} | #{miss_tokens} | #{(100.0 * miss_tokens / tokens_total).round(1)}% |"
io.puts "| pre-split artifacts (counts fan to parts) | #{splits.size} | #{split_tokens} | #{(100.0 * split_tokens / tokens_total).round(1)}% |"
io.puts
io.puts "HSK words by level: " + by_level.map { |l, ws| "L#{l}: #{ws.size}" }.join(", ")
io.puts
io.puts "## Pre-split (deterministic, verified)"
io.puts
io.puts "#{splits.size} artifact tokens split by rule: " +
  splits.group_by { |s| s["rule"] }.map { |k, v| "#{k}: #{v.size}" }.join(", ") + "."
io.puts
splits.group_by { |s| s["rule"] }.each do |rule, list|
  io.puts "**#{rule}**: " + list.map { |s| "#{s["word"]}→#{s["parts"].join("+")}" }.join(", ")
  io.puts
end
io.puts "## Phase A — match step (existing cards)"
io.puts
io.puts "#{a_covered.size}/#{a.size} covered by the existing gloss. Of #{a_new.size} proposed new senses, " \
       "Opus confirmed #{a_confirmed.size}, rejected #{a_rejected.size}."
io.puts
unless a_new.empty?
  io.puts "| word | existing gloss | proposed new sense | confirm | sentence |"
  io.puts "|---|---|---|---|---|"
  a_new.each do |r|
    backs = r["hsk"].map { |h| h["back"] }.uniq.join("; ")
    io.puts "| #{r["word"]} | #{backs} | #{parts(r)[1..].join(" — ")} | #{confirm_cell(confirm[r["word"]])} | #{sent(r)} |"
  end
  io.puts
end
io.puts "## Phase B — new words glossed against CEDICT (#{fixes.(b)} fixed by confirm)"
io.puts
%w[word name artifact].each do |kind|
  list = b_by.fetch(kind, [])
  next if list.empty?
  io.puts "### #{kind} (#{list.size})"
  io.puts
  io.puts "| word | verdict | confirm | sentence |"
  io.puts "|---|---|---|---|"
  list.each { |r| io.puts "| #{r["word"]} | #{parts(r)[1..].join(" / ")} | #{confirm_cell(confirm[r["word"]])} | #{sent(r)} |" }
  io.puts
end
io.puts "## Phase C — not in CEDICT (routing; #{fixes.(c)} fixed by confirm)"
io.puts
%w[name artifact word].each do |kind|
  list = c_by.fetch(kind, [])
  next if list.empty?
  io.puts "### #{kind} (#{list.size})"
  io.puts
  io.puts "| token | verdict | confirm | sentence |"
  io.puts "|---|---|---|---|"
  list.each { |r| io.puts "| #{r["word"]} | #{parts(r)[1..].join(" / ")} | #{confirm_cell(confirm[r["word"]])} | #{sent(r)} |" }
  io.puts
end
io.close
puts "wrote #{OUT}"
