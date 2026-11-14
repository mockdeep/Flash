# frozen_string_literal: true

# One literary work retold at each level of a language's word lists, from
# the level just under the original down to the first, so a learner climbs
# one story to the real book. Its config, chapter headings and texts are
# worked on in drafts/backbones/<name>/, one folder of chapters per level,
# which git ignores: once loaded, the texts live in the database.
class Backbone
  ROOT = Rails.root.join("drafts/backbones")
  CACHE = Rails.root.join("tmp/backbones")
  ORIGINAL = "original"

  # A level's code (B1), the word list that sets it, whether a word above it
  # must be fixed (or is only reported), and what its writer and reviewer
  # hold it to, from grammar to how much of the story it keeps.
  Level = Data.define(:code, :list, :strict, :guidelines)

  class Level
    def initialize(guidelines: "", **) = super
  end

  attr_reader :name, :title, :author, :language, :levels, :title_words, :notes

  def self.find(name, root: ROOT)
    dir = root.join(name)
    new(name, YAML.load_file(dir.join("backbone.yml")), dir:)
  end

  def initialize(name, config, dir:)
    @name = name
    @dir = dir
    @title = config["title"]
    @author = config["author"]
    @language = config["language"]
    @levels = config["levels"].map { Level.new(**it.symbolize_keys) }
    @recurring_words = config.fetch("recurring_words", [])
    @level_words = config.fetch("level_words", {})
    @title_words = config.fetch("title_words", [])
    @notes = config.fetch("notes", "")
  end

  # What the writer's and reviewer's prompts name.
  def prompt_terms
    { work: title, author:, language: WordList::LANGUAGES[language] }
  end

  # Where what can be made again lives: the lemma cache and run logs.
  def cache_dir = CACHE.join(name)

  def level(code)
    levels.find { it.code == code } || raise(ArgumentError, "No level #{code}")
  end

  # The level each is written from; nil for the top one, written from the
  # original.
  def above(level)
    index = levels.index(level)
    levels[index - 1] if index.positive?
  end

  # The level and those below it, whose words a text at the level may use.
  def up_to(level) = levels.drop(levels.index(level))

  # Base forms the story needs that a level's lists don't hold.
  def story_words(level)
    @recurring_words + @level_words.fetch(level.code, [])
  end

  # Chapter names in reading order.
  def chapters = headings.keys

  def text_path(level, chapter) = @dir.join(level.code, "#{chapter}.txt")
  def original_path(chapter) = @dir.join(ORIGINAL, "#{chapter}.txt")

  # The text a level's chapter is written from: the level above's, or the
  # original's.
  def source_path(level, chapter)
    upper = above(level)
    upper ? text_path(upper, chapter) : original_path(chapter)
  end

  # Where a draft that needs a person's eye waits, with why it stopped.
  def draft_path(level, chapter) = @dir.join(level.code, "#{chapter}.draft.txt")

  def trouble_path(level, chapter)
    @dir.join(level.code, "#{chapter}.trouble.md")
  end

  # A version's heading for a chapter ("title" and "translation"), by level
  # code or ORIGINAL; nil until one is written.
  def heading(version, chapter) = headings.dig(chapter, version)

  def heading_title(version, chapter)
    heading(version, chapter)&.fetch("title")
  end

  def save_heading(level, chapter, title:, translation:)
    all = headings
    (all[chapter] ||= {})[level.code] =
      { "title" => title, "translation" => translation }
    headings_path.write(all.to_yaml)
  end

  private

  def headings_path = @dir.join("headings.yml")
  def headings = YAML.load_file(headings_path)
end
