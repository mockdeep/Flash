# Entry-resolution dry run (read-only): can every existing zh language-deck
# front item resolve to a compendium entry (headword + reading)?
# Targets: HSK spine (flash-csvs 02-gloss) then full CC-CEDICT, per the
# migration plan in docs/compendium.md ("headword + the card's stored reading,
# CEDICT fallback when reading is missing").
# Run: bin/rails runner tmp/compendium_prototype/resolve.rb
require "csv"
require "json"

CSVS = "/home/fletch/Dropbox/projects/open_source/flash-csvs/mandarin"

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

sets = DataSet.where(type: "LanguageDataSet", language: "zh").order(:id)
sets.each do |set|
  fronts = set.items.where(side: "Front").order(:id)
  fronts.each do |item|
    w = item.text.strip
    cands = readings.(w)
    label =
      if cands.empty?
        "unresolved"
      elsif item.reading.blank?
        cands.map { |p| norm(p) }.uniq.size == 1 ? "no_reading_unambiguous" : "no_reading_ambiguous"
      elsif cands.any? { |p| norm(p) == norm(item.reading) }
        hsk.key?(w) ? "exact_hsk" : "exact_cedict"
      elsif cands.any? { |p| toneless(p) == toneless(item.reading) }
        "toneless_match"
      else
        "reading_mismatch"
      end
    buckets[[set, label]] << item
  end
end

sets.each do |set|
  rows = buckets.select { |(s, _), _| s == set }
  total = rows.values.sum(&:size)
  puts "\n#{set.name} (id #{set.id}, user #{set.user_id}) — #{total} fronts"
  rows.sort_by { |(_, l), _| l }.each do |(_, label), items|
    puts "  #{label}: #{items.size}"
    next if %w[exact_hsk exact_cedict no_reading_unambiguous].include?(label)
    items.first(10).each do |i|
      puts "    #{i.text} (reading: #{i.reading.inspect}) candidates: #{readings.(i.text.strip).join(" / ")[0, 60]}"
    end
    puts "    ... +#{items.size - 10} more" if items.size > 10
  end
end

all = buckets.values.flatten
clean = buckets.select { |(_, l), _| %w[exact_hsk exact_cedict no_reading_unambiguous toneless_match].include?(l) }.values.flatten
puts "\nTOTAL: #{all.size} fronts, cleanly resolvable: #{clean.size} (#{(100.0 * clean.size / all.size).round(1)}%)"
