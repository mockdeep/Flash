# frozen_string_literal: true

module Backbones
  # The words a backbone's original uses most that the lists at or below a
  # level don't hold, as lines to print: each base form with how often the
  # original uses it, the lowest level that lists it and the forms written.
  # Run before writing, it shows the list gaps and story words to settle
  # first, rather than one stopped draft at a time.
  module Vocabulary
    def self.call(name, level, minimum = "5")
      backbone = Backbone.find(name)
      flags = frequent(backbone, backbone.level(level), Integer(minimum))
      heading = "#{flags.size} base forms the original uses " \
                "#{minimum}+ times above #{level}:"

      [heading, *flags.map { line(it) }]
    end

    def self.frequent(backbone, level, minimum)
      lemmas = Lemmas.in(backbone.language)
      text = original(backbone)
      flags = Check.call(backbone, level, text, lemmas:).flags

      flags.select { count(it) >= minimum }.sort_by { [-count(it), it.base] }
    end

    def self.original(backbone)
      paths = backbone.chapters.map { backbone.original_path(it) }

      paths.select(&:exist?).map(&:read).join("\n")
    end

    def self.count(flag) = flag.forms.values.sum

    def self.line(flag)
      listed = (flag.listed || "-").ljust(4)
      forms = flag.forms.sort_by { -it.last }.map(&:first).join(", ")
      times = count(flag).to_s.rjust(4)

      "  #{times}  #{listed} #{flag.base.ljust(20)} #{forms}"
    end
  end
end
