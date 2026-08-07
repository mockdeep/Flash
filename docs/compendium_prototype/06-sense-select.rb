# Sense-selection experiment (claude CLI, run sandbox OFF): can the match step
# pick WHICH existing sense a sentence uses? Ground truth from flash-csvs:
# headwords at multiple HSK levels with distinct glosses are multi-sense entries,
# and each level's example sentence was verified (07 judge) to use that level's
# sense. Sonnet picks; we score against the sentence's own level.
# Output: output/sense-select/results.jsonl, report-sense-select.md
require "csv"
require "json"
require "fileutils"
require "open3"

DIR = __dir__
require_relative "texts"
CSVS = "/home/fletch/Dropbox/projects/open_source/flash-csvs/mandarin"
OUT  = File.join(OUTPUT_ROOT, "sense-select")
FileUtils.mkdir_p(OUT)
MODEL = "sonnet"
BATCH = 15

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

STOP = %w[to the a an of for in on at be is one's sb sth etc].freeze
def tokens(gloss) = gloss.downcase.scan(/[a-z']+/) - STOP

def distinct?(rows)
  rows.combination(2).all? do |a, b|
    ta, tb = tokens(a[:back]), tokens(b[:back])
    (ta & tb).empty?
  end
end

groups = Hash.new { |h, k| h[k] = [] }
(1..7).each do |lv|
  CSV.foreach(File.join(CSVS, "output/08-translate/#{lv}.csv"), headers: true) do |r|
    next if r["example_front"].to_s.empty? || r["verify_ok"] == "false"
    groups[r["word"]] << { lv: lv, pinyin: r["pinyin"], back: r["back"], sentence: r["example_front"] }
  end
end

eligible = groups.select { |_, rows| rows.size >= 2 && rows.map { |r| r[:back].downcase }.uniq.size == rows.size && distinct?(rows) }
items = eligible.flat_map do |word, rows|
  rows.each_with_index.map do |row, i|
    { word: word, expected: i + 1, sentence: row[:sentence],
      senses: rows.map { |r| "#{r[:pinyin]}: #{r[:back]}" },
      diff_reading: rows.map { |r| r[:pinyin] }.uniq.size > 1 }
  end
end
puts "#{eligible.size} headwords, #{items.size} test items (#{items.count { |i| i[:diff_reading] }} with reading at stake)"

HEADER = <<~P
  You are the sense-selection ("match") step of a vocabulary pipeline. Each numbered item
  gives a Chinese WORD, its candidate SENSES (numbered, each as pinyin: gloss), and a
  SENTENCE using the word. Pick the single sense the sentence uses. If no listed sense
  fits the usage, answer 0.

  Reply with EXACTLY one line per numbered item and nothing else:
    N|<sense number>

P

results = File.open(File.join(OUT, "results.jsonl"), "w")
items.each_slice(BATCH).with_index do |chunk, ci|
  puts "batch #{ci + 1}/#{(items.size / BATCH.to_f).ceil} (#{chunk.size} items)"
  lines = chunk.each_with_index.map do |it, i|
    senses = it[:senses].each_with_index.map { |s, j| "(#{j + 1}) #{s}" }.join("  ")
    "#{i + 1}. #{it[:word]} | senses: #{senses} | sentence: #{it[:sentence]}"
  end
  res = call_claude(HEADER + lines.join("\n"))
  abort "no output" unless res
  parsed = {}
  res.each_line { |l| parsed[$1.to_i] = $2.to_i if l.chomp =~ /\A(\d+)\|(\d+)\z/ }
  chunk.each_with_index do |it, i|
    chosen = parsed[i + 1]
    warn "  no answer for #{it[:word]}" unless chosen
    next unless chosen
    results.puts JSON.generate(it.merge(chosen: chosen, correct: chosen == it[:expected]))
  end
  results.flush
end
results.close

rows = File.foreach(File.join(OUT, "results.jsonl")).map { |l| JSON.parse(l) }
acc = ->(list) { list.empty? ? "n/a" : "#{list.count { |r| r["correct"] }}/#{list.size} (#{(100.0 * list.count { |r| r["correct"] } / list.size).round(1)}%)" }
File.open(File.join(DIR, "report-sense-select.md"), "w") do |io|
  io.puts "# Sense-selection accuracy (match step, Sonnet single pass)"
  io.puts
  io.puts "Ground truth: multi-level HSK headwords with distinct glosses; each level's"
  io.puts "judge-verified example sentence should select that level's sense."
  io.puts
  io.puts "- Overall: #{acc.(rows)}"
  io.puts "- Reading at stake (homograph resolution): #{acc.(rows.select { |r| r["diff_reading"] })}"
  io.puts "- Same reading (pure sense split): #{acc.(rows.reject { |r| r["diff_reading"] })}"
  io.puts "- Answered 0 (no sense fits): #{rows.count { |r| r["chosen"].zero? }}"
  io.puts
  misses = rows.reject { |r| r["correct"] }
  io.puts "## Misses (#{misses.size})"
  io.puts
  misses.each do |r|
    io.puts "- **#{r["word"]}** expected (#{r["expected"]}), chose (#{r["chosen"]}) — senses: #{r["senses"].join(" / ")} — #{r["sentence"]}"
  end
end
puts "wrote report-sense-select.md"
