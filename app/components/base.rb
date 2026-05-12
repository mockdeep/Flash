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
    include Phlex::Rails::Helpers::Translate
    include Phlex::Rails::Helpers::TurboFrameTag

    register_value_helper :current_user

    def supporter_badge
      span(
        class: "supporter-badge",
        title: "Supporter",
        aria: { label: "Supporter" },
      ) { "♥" }
    end

    def music_badge
      span(
        class: "music-badge",
        title: "Microphone required",
        aria: { label: "Microphone required" },
      ) { "🎤" }
    end
  end
end
