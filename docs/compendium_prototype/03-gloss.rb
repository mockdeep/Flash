# LLM pass over the lookup (claude CLI, run sandbox OFF):
#   A (hsk)    — the compendium "match step": does an existing card gloss cover
#                this usage, or is a new sense needed?
#   B (cedict) — contextual glossing of a new word, grounded in CEDICT senses
#   C (miss)   — routing: proper noun / segmentation artifact / real rare word
# Resumable: already-glossed words are skipped on re-run.
# Output: output/03-gloss/gloss.jsonl (verdict stored raw; 04-report parses it)
require "json"
require "fileutils"
require "open3"
require "set"

DIR     = __dir__
require_relative "texts"
SLUG    = ARGV[0] || "kongyiji"
DESC    = TEXTS.fetch(SLUG)
IN      = File.join(OUTPUT_ROOT, "#{SLUG}/02-lookup/lookup.jsonl")
OUT_DIR = File.join(OUTPUT_ROOT, "#{SLUG}/03-gloss")
OUT     = File.join(OUT_DIR, "gloss.jsonl")
FileUtils.mkdir_p(OUT_DIR)
MODEL = "sonnet"
BATCH = 20

def call_claude(prompt, model: MODEL, attempts: 5)
  attempts.times do |i|
    stdout, _e, status = Open3.capture3({ "CLAUDECODE" => nil }, "claude", "-p", "--model", model, prompt)
    out = status.success? ? stdout.gsub(/\A```[a-z]*\n?/, "").gsub(/\n?```\z/, "").strip : ""
    return out unless out.empty?
    warn "  empty response (#{i + 1}/#{attempts}, #{model})"
    sleep([5 * (3**i), 60].min) if i + 1 < attempts
  rescue => e
    warn "  error (#{i + 1}/#{attempts}): #{e.message}"
    sleep([5 * (3**i), 60].min) if i + 1 < attempts
  end
  nil
end

HEADER_A = <<~P
  You are the "match step" of a vocabulary pipeline building a study list for #{DESC}.
  Each numbered line gives a Chinese WORD, the GLOSS on the word's existing flashcard,
  and the SENTENCE where the word first appears in the text.

  Decide whether the existing gloss covers the word's meaning in that sentence:
  - covered — a learner who knows this gloss would understand the word here
    (register or minor nuance differences still count as covered).
  - new — the sentence uses a genuinely different sense the gloss does not teach.
    Give a concise English learner gloss for THAT sense (no hanzi in the gloss).

  Reply with EXACTLY one line per numbered item and nothing else:
    N|covered
    N|new|<concise gloss for the sense used here>

P

HEADER_B = <<~P
  You are glossing new vocabulary for a study list for #{DESC}.
  Each numbered line gives a Chinese WORD, its CC-CEDICT senses (each as [pinyin] meanings),
  and the SENTENCE where the word first appears in the text.

  Pick the sense actually in use and write a concise English learner gloss (flashcard
  style, no hanzi, drop dictionary annotations). Classify the word:
  - word — ordinary vocabulary
  - name — proper noun; gloss it contextually for a reader of this story
    (e.g. "Kong Yiji — the protagonist")
  - artifact — this is not really one word here (bad segmentation); explain briefly

  Reply with EXACTLY one line per numbered item and nothing else:
    N|word|<pinyin>|<gloss>
    N|name|<pinyin>|<gloss>
    N|artifact|<explanation>

P

HEADER_C = <<~P
  You are routing unknown tokens for a vocabulary pipeline processing #{DESC}.
  Each numbered line gives a TOKEN produced by word segmentation that
  was NOT found in CC-CEDICT, and the SENTENCE where it first appears.

  Classify each token:
  - name — a proper noun; give pinyin and a contextual gloss for a reader of this text
  - artifact — bad segmentation, not a real word; show how the span should split
  - word — a real word CEDICT lacks (including era/variant spellings for the text's
    period; note the modern form in parens if so); give pinyin and a concise learner gloss

  Reply with EXACTLY one line per numbered item and nothing else:
    N|name|<pinyin>|<gloss>
    N|artifact|<correct split, e.g. 甲|乙>
    N|word|<pinyin>|<gloss>

P

def cedict_summary(entries)
  entries.map { |e| "[#{e["pinyin"]}] #{e["meanings"].join("; ")}" }.join(" / ")[0, 400]
end

def run_phase(rows, header, phase, out)
  rows.each_slice(BATCH).with_index do |chunk, ci|
    puts "phase #{phase}: batch #{ci + 1} (#{chunk.size} words)"
    lines = chunk.each_with_index.map { |r, i| yield(r, i + 1) }
    res = call_claude(header + lines.join("\n"))
    abort "phase #{phase}: no output from claude" unless res
    parsed = {}
    res.each_line do |line|
      parsed[$1.to_i] = $2.strip if line.chomp =~ /\A(\d+)\|(.+)\z/
    end
    chunk.each_with_index do |r, i|
      v = parsed[i + 1]
      warn "  no verdict for #{r["word"]}" unless v
      next unless v
      out.puts JSON.generate(r.merge("phase" => phase, "verdict" => v))
    end
    out.flush
  end
end

rows = File.foreach(IN).map { |l| JSON.parse(l) }
current = rows.to_h { |r| [r["word"], r["status"]] }

# prune cached rows for words the lookup no longer contains (or whose status changed)
if File.exist?(OUT)
  cached = File.foreach(OUT).map { |l| JSON.parse(l) }
  kept = cached.select { |r| current[r["word"]] == r["status"] }
  if kept.size < cached.size
    puts "pruned #{cached.size - kept.size} stale cached rows"
    File.open(OUT, "w") { |f| kept.each { |r| f.puts JSON.generate(r) } }
  end
end

done = File.exist?(OUT) ? File.foreach(OUT).map { |l| JSON.parse(l)["word"] }.to_set : Set.new
pending = rows.reject { |r| done.include?(r["word"]) }
puts "#{rows.size} words, #{pending.size} pending"

out = File.open(OUT, "a")

run_phase(pending.select { |r| r["status"] == "hsk" }, HEADER_A, "A", out) do |r, n|
  backs = r["hsk"].map { |h| h["back"] }.uniq.join("; ")
  "#{n}. #{r["word"]} | gloss: #{backs} | sentence: #{r["sentence"]}"
end

run_phase(pending.select { |r| r["status"] == "cedict" }, HEADER_B, "B", out) do |r, n|
  "#{n}. #{r["word"]} | senses: #{cedict_summary(r["cedict"])} | sentence: #{r["sentence"]}"
end

run_phase(pending.select { |r| r["status"] == "miss" }, HEADER_C, "C", out) do |r, n|
  "#{n}. #{r["word"]} | sentence: #{r["sentence"]}"
end

out.close
puts "done: #{File.foreach(OUT).count} rows in #{OUT}"
