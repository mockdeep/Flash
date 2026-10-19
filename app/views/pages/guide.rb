# frozen_string_literal: true

module Views
  module Pages
    class Guide < Views::Base
      def view_template
        div(class: "guide") do
          h1 { "How Flash Works" }
          render_lead
          render(Components::GuideRounds.new)
          render(Components::GuideGoals.new)
          render(Components::GuideReading.new)
        end
      end

      private

      def render_lead
        p(class: "guide__lead") do
          <<~TEXT
            Flash isn't just multiple choice. Each card starts easy and gets
            harder as you go, until you can recall the answer on your own.
          TEXT
        end
      end
    end
  end
end
