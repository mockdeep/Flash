# frozen_string_literal: true

module Components
  # The links between section pages: back to the decks page, then each
  # language the user can study, then Basic and Music, the one being viewed
  # marked as current.
  class SectionSelector < Components::Base
    attr_accessor :sections, :current

    def initialize(sections:, current:)
      super()
      self.sections = sections
      self.current = current
    end

    def view_template
      nav(class: "section-selector", aria: { label: "Sections" }) do
        link_to("All decks", decks_path, class: "section-selector__link")
        sections.each { render_link(it) }
      end
    end

    private

    def render_link(section)
      current = ("page" if section.anchor == self.current.anchor)

      link_to(
        section.name,
        section_decks_path(section.anchor),
        class: "section-selector__link",
        aria: { current: },
      )
    end
  end
end
