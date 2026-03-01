# frozen_string_literal: true

module Components
  class Base < Phlex::HTML
    include CssHelper
    include Phlex::Rails::Helpers::ButtonTo
    include Phlex::Rails::Helpers::FormWith
    include Phlex::Rails::Helpers::ImageTag
    include Phlex::Rails::Helpers::LinkTo
    include Phlex::Rails::Helpers::MailTo
    include Phlex::Rails::Helpers::Pluralize
    include Phlex::Rails::Helpers::Routes
    include Phlex::Rails::Helpers::TurboFrameTag

    register_value_helper :current_user
  end
end
