# frozen_string_literal: true

module Components
  # The Read tab: a deck's snippets as plain text.
  class SnippetReading < Components::Base
    attr_accessor :snippets

    def initialize(snippets:)
      super()
      self.snippets = snippets
    end

    def view_template
      div(class: "reading-snippets") do
        snippets.each { |snippet| render_snippet(snippet) }
      end
    end

    private

    def render_snippet(snippet)
      section(class: "reading-snippet") do
        h2 { snippet.title }
        author = snippet.author
        p(class: "reading-snippet__author") { author } if author.present?
        paragraphs(snippet).each { |paragraph| p { paragraph } }
      end
    end

    def paragraphs(snippet) = snippet.body.split(/\s*\n\s*/).compact_blank
  end
end
