# Segment the prototype text into words, keeping first-occurrence context.
# Output: output/01-segment/words.jsonl — one row per unique Han word, in
# first-appearance order (the compendium's sense_memberships.position).
require "cppjieba_rb"
require "json"
require "fileutils"

DIR  = __dir__
require_relative "texts"
SLUG = ARGV[0] || "kongyiji"
TEXTS.fetch(SLUG)
TEXT = File.join(DIR, "#{SLUG}.txt")
OUT  = File.join(OUTPUT_ROOT, "#{SLUG}/01-segment")
CSVS = "/home/fletch/Dropbox/projects/open_source/flash-csvs/mandarin"
USER_DICT = File.join(CSVS, "data/jieba-user-dict.txt")
abort "missing #{USER_DICT}" unless File.exist?(USER_DICT)

SEG = CppjiebaRb::Internal.new(
  CppjiebaRb::DICT_PATH, CppjiebaRb::HMM_DICT_PATH,
  USER_DICT,
  CppjiebaRb::IDF_PATH, CppjiebaRb::STOP_WORD_PATH,
)

FileUtils.mkdir_p(OUT)

words = {}
seq = 0
paras = File.read(TEXT).split("\n\n")
paras.each_with_index do |para, pi|
  para.split(/(?<=[。！？；])/).each do |sent|
    SEG.segment(sent, :mix, 8, true).each do |tok|
      next unless tok =~ /\p{Han}/
      if (rec = words[tok])
        rec[:count] += 1
      else
        seq += 1
        words[tok] = { seq: seq, para: pi + 1, count: 1, sentence: sent.strip }
      end
    end
  end
end

File.open(File.join(OUT, "words.jsonl"), "w") do |f|
  words.each { |w, rec| f.puts JSON.generate({ word: w }.merge(rec)) }
end
puts "paragraphs: #{paras.size}, han tokens: #{words.values.sum { |r| r[:count] }}, unique words: #{words.size}"
