# frozen_string_literal: true

module Views
  class Base < Components::Base
    def around_template
      render(Views::Layouts::Application.new) do
        super
      end
    end
  end
end
