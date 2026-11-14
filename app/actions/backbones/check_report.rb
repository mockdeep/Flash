# frozen_string_literal: true

module Backbones
  # The words above level in a backbone's texts, as lines to print: every
  # text written so far, or those of the one level or chapter named. A blank
  # level or chapter means all of them, so a chapter can be named alone.
  module CheckReport
    CACHE = Rails.root.join("tmp/backbones")

    def self.call(name, level = nil, chapter = nil)
      backbone = Backbone.find(name)
      lemmas = Lemmas.new(CACHE.join(name, "lemmas.json"))

      texts(backbone, level, chapter).flat_map do |at, chapter_name, path|
        result = Check.call(backbone, at, path.read, lemmas:)
        lines(at, chapter_name, result)
      end
    end

    # Each text written, as its level, chapter and file.
    def self.texts(backbone, level, chapter)
      levels = level.presence ? [backbone.level(level)] : backbone.levels
      chapters = chapter.presence ? [chapter] : backbone.chapters

      levels.product(chapters).filter_map do |at, chapter_name|
        path = backbone.text_path(at, chapter_name)
        [at, chapter_name, path] if path.exist?
      end
    end

    def self.lines(level, chapter, result)
      verdict = result.clean? ? "clean" : "above level"

      [
        "#{level.code} #{chapter}: #{result.words} words, #{verdict}",
        *result.flags.map { flag_line(it) },
        *unknown_line(result.unknown),
      ]
    end

    def self.flag_line(flag)
      forms = flag.forms.map { |form, n| n > 1 ? "#{form}×#{n}" : form }
      listed = (flag.listed || "-").ljust(4)

      "  #{listed} #{flag.base.ljust(22)} #{forms.join(", ")}"
    end

    def self.unknown_line(unknown)
      unknown.any? ? ["  no answer for: #{unknown.join(", ")}"] : []
    end
  end
end
