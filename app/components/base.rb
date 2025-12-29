# frozen_string_literal: true

module Components
  class Base < Phlex::HTML
    include Phlex::Rails::Helpers::FormWith
    include Phlex::Rails::Helpers::ButtonTo
    include Phlex::Rails::Helpers::Routes
    include Phlex::Rails::Helpers::Pluralize

    register_value_helper :current_user
  end
end
