# frozen_string_literal: true

module Views
  module ReadingMaps
    class Show < Views::Base
      attr_accessor :chart

      def initialize(chart:)
        super()
        self.chart = chart
      end

      def view_template
        div(class: "decks-container") do
          h1(class: "decks-title") { chart.name }

          render(Components::MapChart.new(chart:))
        end
      end
    end
  end
end
