# frozen_string_literal: true

module Backbones
  # Writes a backbone's missing texts, chapter by chapter in reading order
  # and each top-down, since a level is written from the one above. A text
  # already written is left alone. A draft that stops waits beside its text
  # with why it stopped, and the rest of its chapter waits with it, until a
  # person saves it as the text. Returns a line per text it wrote, stopped
  # or couldn't start, then the headings it proposed. A blank chapter or
  # level means all of them.
  module Run
    def self.call(name, chapter = nil, level = nil)
      backbone = Backbone.find(name)
      lemmas = Lemmas.new(backbone.cache_dir.join("lemmas.json"))
      chapters = chapter.presence ? [chapter] : backbone.chapters
      levels = level.presence ? [backbone.level(level)] : backbone.levels
      headings = []

      lines =
        chapters.flat_map do |each|
          chapter_lines(backbone, each, levels, lemmas, headings)
        end
      lines + heading_lines(headings)
    end

    def self.chapter_lines(backbone, chapter, levels, lemmas, headings)
      levels.each_with_object([]) do |level, lines|
        waiting = waiting(backbone, level, chapter)
        next if waiting == :written
        break lines << "#{chapter} #{level.code}: #{waiting}" if waiting

        outcome = Write.call(backbone, level, chapter, lemmas:)
        lines << save(backbone, level, chapter, outcome, headings)
        break lines unless outcome.done?
      end
    end

    # Why a text can't be written now, :written when it has been, or nil
    # when it can.
    def self.waiting(backbone, level, chapter)
      return :written if backbone.text_path(level, chapter).exist?
      if backbone.trouble_path(level, chapter).exist?
        return "waiting on its stopped draft"
      end
      return if backbone.source_path(level, chapter).exist?

      "waiting on #{backbone.above(level)&.code || Backbone::ORIGINAL}"
    end

    def self.save(backbone, level, chapter, outcome, headings)
      log_path(backbone, level, chapter).write(outcome.log.join("\n"))
      return stopped(backbone, level, chapter, outcome) unless outcome.done?

      draft = outcome.draft
      written(backbone, level, chapter, draft)
      headings << "#{chapter} #{level.code}: #{heading(draft)}"
      "#{chapter} #{level.code}: written"
    end

    def self.written(backbone, level, chapter, draft)
      write(backbone.text_path(level, chapter), draft.text)
      title = draft.title
      translation = draft.translation
      backbone.save_heading(level, chapter, title:, translation:)
    end

    def self.heading(draft) = "#{draft.title} (#{draft.translation})"

    def self.stopped(backbone, level, chapter, outcome)
      draft = outcome.draft
      write(backbone.draft_path(level, chapter), draft.text)
      backbone.trouble_path(level, chapter).write(<<~TEXT)
        # #{chapter} #{level.code}: #{outcome.trouble}

        Title: #{heading(draft)}

        #{outcome.log.join("\n")}
      TEXT
      "#{chapter} #{level.code}: stopped, #{outcome.trouble}"
    end

    def self.write(path, text)
      FileUtils.mkdir_p(path.dirname)
      path.write("#{text.strip}\n")
    end

    def self.log_path(backbone, level, chapter)
      dir = backbone.cache_dir.join("logs")
      FileUtils.mkdir_p(dir)
      dir.join("#{chapter}-#{level.code}.log")
    end

    def self.heading_lines(headings)
      return [] if headings.empty?

      ["", "Headings to look over:", *headings.map { "  #{it}" }]
    end
  end
end
