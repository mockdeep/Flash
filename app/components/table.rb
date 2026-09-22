# frozen_string_literal: true

module Components
  # The `.table` pattern. The block runs once per row and fills it by
  # calling `cell` on the table it is handed.
  class Table < Components::Base
    attr_accessor :headings, :rows

    def initialize(headings:, rows:)
      super()
      self.headings = headings
      self.rows = rows
    end

    def view_template
      table(class: "table") do
        thead { tr { headings.each { |heading| render_heading(heading) } } }
        tbody do
          rows.each { |row| tr(class: "table__row") { yield(self, row) } }
        end
      end
    end

    def cell(&) = td(class: "table__cell", &)

    private

    def render_heading(heading) = th(class: "table__heading") { heading }
  end
end
