# frozen_string_literal: true

module Components
  # Study | Read radios; a `:has()` rule in flash.css shows the study frame
  # or the snippet text to match, so switching keeps both in place.
  class StudyTabs < Components::Base
    def view_template
      div(class: "study-tabs") do
        render_tab("Study", "study", checked: true)
        render_tab("Read", "read")
      end
    end

    private

    def render_tab(text, value, checked: false)
      id = "study-tab-#{value}"
      input(
        type: "radio",
        name: "study-tab",
        id:,
        value:,
        checked:,
        class: "study-tabs__input",
      )
      label(for: id, class: "study-tabs__tab") { text }
    end
  end
end
