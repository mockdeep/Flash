# frozen_string_literal: true

module Views
  module Welcome
    class Index < Views::Base
      def view_template
        h1 { "Welcome" }
      end
    end
  end
end
