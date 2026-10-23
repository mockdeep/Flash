# frozen_string_literal: true

module Components
  # Picks which section of the deck's source to study, once it has more
  # than one: each opens the user's deck for that section.
  class SectionPicker < Components::Base
    def initialize(deck:)
      super()
      @deck = deck
    end

    def render? = sections.many?

    def view_template
      details(class: "section-picker") do
        summary(class: "section-picker__summary") do
          "Section: #{@deck.snippet.label}"
        end
        div(class: "section-picker__options") do
          sections.each { |snippet| render_option(snippet) }
        end
      end
    end

    private

    def sections
      @sections ||=
        @deck.snippets.studyable.select(:id, :source_id, :heading).to_a
    end

    def render_option(snippet)
      button_to(
        snippet.label,
        deck_section_path(@deck),
        params: { snippet_id: snippet.id },
        class: "section-picker__option",
        aria: { current: ("true" if snippet.id == @deck.snippet_id) },
      )
    end
  end
end
