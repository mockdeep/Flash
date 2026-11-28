# frozen_string_literal: true

module Views
  module Readings
    class Show < Views::Base
      def initialize(deck:, pages:, page:)
        super()
        @deck = deck
        @pages = pages
        @page = page
      end

      def view_template
        render(
          Components::SnippetReading.new(
            deck: @deck,
            pages: @pages,
            page: @page,
          ),
        )
      end
    end
  end
end
