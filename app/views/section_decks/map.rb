# frozen_string_literal: true

module Views
  module SectionDecks
    # A language's page: its reading map.
    class Map < Views::Base
      attr_accessor :section, :sections

      def initialize(section:, sections:)
        super()
        self.section = section
        self.sections = sections
      end

      def view_template
        chart = ::ReadingMap::Chart.new(
          user: current_user, language: section.language,
        )

        div(class: "decks-container") do
          render(Components::SectionSelector.new(sections:, current: section))
          render(Components::MapChart.new(chart:))
        end
      end
    end
  end
end
