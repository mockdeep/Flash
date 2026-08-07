# LLM segmentation experiment (claude CLI, run sandbox OFF): segment the text
# with Sonnet instead of jieba. Each sentence's tokens are mechanically verified
# (concatenation must reproduce the source exactly); failures retry singly, then
# fall out with a count. Output mirrors 01-segment for diffing:
#   output/<slug>/01b-segment-llm/words.jsonl + stats.json
require "json"
require "fileutils"
require "open3"

DIR = __dir__
require_relative "texts"
SLUG = ARGV[0] || "kongyiji"
DESC = TEXTS.fetch(SLUG)
TEXT = File.join(DIR, "#{SLUG}.txt")
OUT  = File.join(OUTPUT_ROOT, "#{SLUG}/01b-segment-llm")
FileUtils.mkdir_p(OUT)
MODEL = "sonnet"
BATCH = 12

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

HEADER = <<~P
  Segment each numbered Chinese sentence into words. The text is #{DESC}.

  Rules:
  - Dictionary-word granularity (CC-CEDICT entries): compounds that are dictionary
    words stay together; grammatical particles (的 了 着 过 吗 呢) are separate tokens.
  - Multi-character proper names (people, places, titles) stay as ONE token.
  - A number and its measure word are separate tokens (一 / 碗).
  - Punctuation marks are their own tokens.
  - Preserve every character EXACTLY as written (including variant/archaic forms);
    the tokens joined together must reproduce the sentence character for character.

  Reply with EXACTLY one line per numbered sentence and nothing else:
    N: word1 / word2 / word3 / ...

P

def segment_batch(sentences_with_idx)
  lines = sentences_with_idx.each_with_index.map { |(s, _), i| "#{i + 1}. #{s}" }
  res = call_claude(HEADER + lines.join("\n"))
  return {} unless res
  parsed = {}
  res.each_line do |line|
    next unless line.chomp =~ /\A(\d+):\s*(.+)\z/
    parsed[$1.to_i] = $2.strip.split(%r{\s*/\s*}).reject(&:empty?)
  end
  parsed
end

# Compare only Han characters: punctuation tokens are discarded downstream, and
# models normalize quote glyphs (“ -> ") — the only failure cause ever observed.
# Dropped, substituted, or invented Han characters still fail.
def verified?(sentence, tokens)
  tokens.join.gsub(/[^\p{Han}]/, "") == sentence.gsub(/[^\p{Han}]/, "")
end

sentences = []
paras = File.read(TEXT).split("\n\n")
paras.each_with_index do |para, pi|
  para.split(/(?<=[。！？；])/).each { |s| sentences << [s.strip, pi + 1] }
end

# sentence-level cache: verified segmentations persist across runs (indices are
# stable — same text, same splitting)
cache_path = File.join(OUT, "segmented.jsonl")
segmented = {} # index in sentences => tokens
if File.exist?(cache_path)
  File.foreach(cache_path) { |l| r = JSON.parse(l); segmented[r["si"]] = r["tokens"] }
  puts "cache: #{segmented.size}/#{sentences.size} sentences already verified"
end
cache = File.open(cache_path, "a")

failed = (0...sentences.size).to_a - segmented.keys
attempts = Hash.new { |h, k| h[k] = [] } # si => [{round:, tokens:}]
retries = 0

2.times do |round|
  break if failed.empty?
  batch_size = round.zero? ? BATCH : 1
  still_failed = []
  failed.each_slice(batch_size).with_index do |idx_chunk, ci|
    puts "round #{round + 1}: batch #{ci + 1} (#{idx_chunk.size} sentences)"
    chunk = idx_chunk.map { |i| sentences[i] }
    parsed = segment_batch(chunk)
    idx_chunk.each_with_index do |si, i|
      toks = parsed[i + 1]
      if toks && verified?(sentences[si][0], toks)
        segmented[si] = toks
        cache.puts JSON.generate({ "si" => si, "tokens" => toks })
        cache.flush
      else
        attempts[si] << { "round" => round + 1, "tokens" => toks }
        retries += 1 if round.zero?
        still_failed << si
      end
    end
  end
  failed = still_failed
end
cache.close

File.open(File.join(OUT, "failures.jsonl"), "w") do |f|
  failed.each do |si|
    sent, para = sentences[si]
    f.puts JSON.generate({ "si" => si, "para" => para, "sentence" => sent, "attempts" => attempts[si] })
  end
end

words = {}
seq = 0
sentences.each_with_index do |(sent, para), si|
  next unless (toks = segmented[si])
  toks.each do |tok|
    next unless tok =~ /\p{Han}/
    if (rec = words[tok])
      rec[:count] += 1
    else
      seq += 1
      words[tok] = { seq: seq, para: para, count: 1, sentence: sent }
    end
  end
end

File.open(File.join(OUT, "words.jsonl"), "w") do |f|
  words.each { |w, rec| f.puts JSON.generate({ word: w }.merge(rec)) }
end
stats = {
  sentences: sentences.size,
  verified: segmented.size,
  retried: retries,
  unrecovered: sentences.size - segmented.size,
  han_tokens: words.values.sum { |r| r[:count] },
  unique_words: words.size,
}
File.write(File.join(OUT, "stats.json"), JSON.pretty_generate(stats))
puts stats.inspect
