# Opus confirm tier over the Sonnet verdicts (claude CLI, run sandbox OFF) —
# mirrors flash-csvs's propose->confirm shape. Confirms:
#   A rows with a "new" verdict  — is the proposed sense correct AND genuinely
#                                  not taught by the existing gloss?
#   B rows (all)                 — is the gloss the right sense for this usage?
#   C rows (all)                 — is the routing classification + gloss right?
# "covered" A verdicts are not re-judged (matching flash-csvs: confirm proposals,
# not passes). Resumable. Output: output/03b-confirm/confirm.jsonl with
# confirm = "ok" or "reject|<reason>" or "fix|<replacement in the phase's format>"
require "json"
require "fileutils"
require "open3"
require "set"

DIR     = __dir__
require_relative "texts"
SLUG    = ARGV[0] || "kongyiji"
DESC    = TEXTS.fetch(SLUG)
IN      = File.join(OUTPUT_ROOT, "#{SLUG}/03-gloss/gloss.jsonl")
OUT_DIR = File.join(OUTPUT_ROOT, "#{SLUG}/03b-confirm")
OUT     = File.join(OUT_DIR, "confirm.jsonl")
FileUtils.mkdir_p(OUT_DIR)
MODEL = "opus"
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
  You are the confirm tier of a vocabulary pipeline for #{DESC}. A first-pass
  model claimed each word below is used in a sense its existing flashcard does NOT teach, and
  proposed a new sense. Each numbered line: WORD | existing card GLOSS | PROPOSED new sense |
  the SENTENCE in question.

  Confirm ONLY if the proposal is BOTH correct for the sentence AND genuinely not taught by
  the existing gloss (a nuance, register shift, or grammatical variation of a taught meaning
  is NOT a new sense — reject those). Be calibrated to actually reject weak proposals.

  Reply with EXACTLY one line per numbered item and nothing else:
    N|ok
    N|reject|<short reason>

P

HEADER_B = <<~P
  You are the confirm tier of a vocabulary pipeline for #{DESC}. A first-pass
  model glossed each new word from its CC-CEDICT entry and the text's context. Each numbered
  line: WORD | CEDICT senses | PROPOSED verdict (kind|pinyin|gloss) | SENTENCE.

  Check: right sense for this usage, correct pinyin, concise English-only learner gloss,
  correct kind (word / name / artifact). If anything is wrong, supply the corrected verdict
  in the same kind|pinyin|gloss format.

  Reply with EXACTLY one line per numbered item and nothing else:
    N|ok
    N|fix|<kind>|<pinyin>|<gloss>

P

HEADER_C = <<~P
  You are the confirm tier of a vocabulary pipeline for #{DESC}. A first-pass
  model classified each token below, none of which appear in CC-CEDICT. Each numbered line:
  TOKEN | PROPOSED verdict (name|pinyin|gloss, artifact|split, or word|pinyin|gloss) | SENTENCE.

  Check the classification and the gloss/split. If anything is wrong, supply the corrected
  verdict in the same format.

  Reply with EXACTLY one line per numbered item and nothing else:
    N|ok
    N|fix|<corrected verdict in the same format>

P

def cedict_summary(entries)
  entries.map { |e| "[#{e["pinyin"]}] #{e["meanings"].join("; ")}" }.join(" / ")[0, 400]
end

def run_confirm(rows, header, out)
  rows.each_slice(BATCH).with_index do |chunk, ci|
    puts "confirm #{chunk.first["phase"]}: batch #{ci + 1} (#{chunk.size} words)"
    lines = chunk.each_with_index.map { |r, i| yield(r, i + 1) }
    res = call_claude(header + lines.join("\n"))
    abort "confirm: no output from claude" unless res
    parsed = {}
    res.each_line do |line|
      parsed[$1.to_i] = $2.strip if line.chomp =~ /\A(\d+)\|(.+)\z/
    end
    chunk.each_with_index do |r, i|
      v = parsed[i + 1]
      warn "  no confirm verdict for #{r["word"]}" unless v
      next unless v
      out.puts JSON.generate({ "word" => r["word"], "phase" => r["phase"], "confirm" => v })
    end
    out.flush
  end
end

rows = File.foreach(IN).map { |l| JSON.parse(l) }
done = File.exist?(OUT) ? File.foreach(OUT).map { |l| JSON.parse(l)["word"] }.to_set : Set.new

a_new = rows.select { |r| r["phase"] == "A" && r["verdict"].start_with?("new") && !done.include?(r["word"]) }
b_all = rows.select { |r| r["phase"] == "B" && !done.include?(r["word"]) }
c_all = rows.select { |r| r["phase"] == "C" && !done.include?(r["word"]) }
puts "to confirm — A(new): #{a_new.size}, B: #{b_all.size}, C: #{c_all.size}"

out = File.open(OUT, "a")

run_confirm(a_new, HEADER_A, out) do |r, n|
  backs = r["hsk"].map { |h| h["back"] }.uniq.join("; ")
  proposed = r["verdict"].split("|", 2)[1]
  "#{n}. #{r["word"]} | gloss: #{backs} | proposed: #{proposed} | sentence: #{r["sentence"]}"
end

run_confirm(b_all, HEADER_B, out) do |r, n|
  "#{n}. #{r["word"]} | senses: #{cedict_summary(r["cedict"])} | proposed: #{r["verdict"]} | sentence: #{r["sentence"]}"
end

run_confirm(c_all, HEADER_C, out) do |r, n|
  "#{n}. #{r["word"]} | proposed: #{r["verdict"]} | sentence: #{r["sentence"]}"
end

out.close
puts "done: #{File.foreach(OUT).count} rows in #{OUT}"
