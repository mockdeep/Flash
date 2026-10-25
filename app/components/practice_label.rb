# frozen_string_literal: true

module Components
  class PracticeLabel < Components::Base
    def view_template
      p(class: "keyboard-hint") { "Practice — streaks won't change" }
    end
  end
end
