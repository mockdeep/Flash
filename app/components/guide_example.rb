# frozen_string_literal: true

module Components
  class GuideExample < Components::Base
    def initialize(caption:)
      super()
      @caption = caption
    end

    def view_template(&)
      figure(class: "guide__example") do
        yield
        figcaption { @caption }
      end
    end
  end
end
