# frozen_string_literal: true

module Backbones
  # Puts a backbone's written chapters into the app: a source per version,
  # owned by the user named, and a snippet per chapter, headed by its Roman
  # numeral and its title, as the original prints it. A source's snippets
  # are in the order they were added, so a version's chapters go in strictly
  # in reading order: after the ones it already holds, and only while each
  # next one is written with its heading. It can run again as more chapters
  # are written. Returns a line per version.
  module Load
    class Failed < StandardError; end

    def self.call(name, username)
      backbone = Backbone.find(name)
      user = User.find_by!(username:)

      backbone.versions.map { load(backbone, user, it) }
    end

    def self.load(backbone, user, version)
      attributes = backbone.source_attributes(version)
      source = user.sources.find_by(title: attributes[:title])
      ready = ready(backbone, version, source&.snippets&.count || 0)
      return "#{attributes[:title]}: nothing to add" if ready.empty?

      source ||= create_source(backbone, user, attributes)
      ready.each { add(backbone, source, version, it) }
      "#{source.title}: added #{ready.join(", ")}"
    end

    # The chapters after those already loaded that are written and headed,
    # up to the first that isn't.
    def self.ready(backbone, version, loaded)
      backbone.chapters.drop(loaded).take_while do |chapter|
        backbone.path(version, chapter).exist? &&
          backbone.heading(version, chapter)
      end
    end

    def self.create_source(backbone, user, attributes)
      result =
        Sources::Create.call(user:, language: backbone.language, **attributes)
      saved(result)
    end

    def self.add(backbone, source, version, chapter)
      heading = backbone.heading(version, chapter)
      result = Snippets::Create.call(
        source:,
        heading: "#{chapter} — #{heading["title"]}",
        heading_translation: "#{chapter} — #{heading["translation"]}",
        body: backbone.path(version, chapter).read.strip,
      )
      saved(result)
    end

    def self.saved(result)
      return result.record if result.success?

      raise(Failed, result.record.errors.full_messages.join(", "))
    end
  end
end
