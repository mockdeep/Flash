# frozen_string_literal: true

module Views
  module Layouts
    class Application < Components::Base
      include Phlex::Rails::Helpers::CSRFMetaTags
      include Phlex::Rails::Helpers::CSPMetaTag
      include Phlex::Rails::Helpers::StylesheetLinkTag
      include Phlex::Rails::Helpers::JavascriptIncludeTag
      include Phlex::Rails::Helpers::LinkTo
      include Phlex::Rails::Helpers::Flash

      def view_template
        doctype

        html do
          head do
            title { "Flash" }
            csrf_meta_tags
            csp_meta_tag

            stylesheet_link_tag("application", media: "all")
            stylesheet_link_tag("flash", media: "all")
            javascript_include_tag("application")
          end

          action = "keydown@document->hotkeys#handleKeydown"
          body(data: { controller: "hotkeys", action: }) do
            if current_user.logged_in?
              plain(current_user.email)
              plain(" | ")
              link_to("Account", account_path)
              button_to("Log Out", session_path, method: :delete)
            else
              link_to("Log In", new_session_path)
              plain(" | ")
              link_to("Sign Up", new_account_path)
            end

            div(class: "flashes") do
              flash.each do |type, message|
                div(class: "flash-#{type}") { message }
              end
            end

            yield

            footer do
              plain("Please send feedback to ")
              mail_to("support+flash@boon.gl")
              br
              plain(" or feel free to open an issue on ")
              link_to("the Github Repo", repo_url)
              br
              link_to("Privacy Policy", privacy_path)
              plain(" | ")
              link_to("Terms of Service", terms_path)
            end
          end
        end
      end

      private

      def repo_url
        "https://www.github.com/mockdeep/flash"
      end
    end
  end
end
