# frozen_string_literal: true

# One literary work retold at each level of a language's word lists, from
# the level just under the original down to the first, so a learner climbs
# one story to the real book. Its config, chapter headings and texts are
# worked on in drafts/backbones/<name>/, one folder of chapters per level,
# which git ignores: once loaded, the texts live in the database.
class Backbone
  ROOT = Rails.root.join("drafts/backbones")

  # A level's code (B1), the word list that sets it, whether a word above it
  # must be fixed (or is only reported), and its target length as a share
  # of the original chapter.
  Level = Data.define(:code, :list, :strict, :share)

  attr_reader :name, :language, :levels, :title_words

  def self.find(name, root: ROOT)
    dir = root.join(name)
    new(name, YAML.load_file(dir.join("backbone.yml")), dir:)
  end

  def initialize(name, config, dir:)
    @name = name
    @dir = dir
    @language = config["language"]
    @levels = config["levels"].map { Level.new(**it.symbolize_keys) }
    @recurring_words = config.fetch("recurring_words", [])
    @level_words = config.fetch("level_words", {})
    @title_words = config.fetch("title_words", [])
  end

  def level(code)
    levels.find { it.code == code } || raise(ArgumentError, "No level #{code}")
  end

  # The level and those below it, whose words a text at the level may use.
  def up_to(level) = levels.drop(levels.index(level))

  # Base forms the story needs that a level's lists don't hold.
  def story_words(level)
    @recurring_words + @level_words.fetch(level.code, [])
  end

  # Chapter names in reading order.
  def chapters = YAML.load_file(@dir.join("headings.yml")).keys

  def text_path(level, chapter) = @dir.join(level.code, "#{chapter}.txt")
end
