# frozen_string_literal: true

module Views
  module Layouts
    class Application < Components::Base
      include Phlex::Rails::Helpers::CSRFMetaTags
      include Phlex::Rails::Helpers::CSPMetaTag
      include Phlex::Rails::Helpers::StylesheetLinkTag
      include Phlex::Rails::Helpers::JavascriptIncludeTag
      include Phlex::Rails::Helpers::LinkTo
      include Phlex::Rails::Helpers::ButtonTo
      include Phlex::Rails::Helpers::MailTo
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
            stylesheet_link_tag("layout", media: "all")
            stylesheet_link_tag("welcome", media: "all")
            stylesheet_link_tag("decks", media: "all")
            stylesheet_link_tag("pricing", media: "all")
            javascript_include_tag("application")
          end

          action = "keydown@document->hotkeys#handleKeydown"
          body(data: { controller: "hotkeys", action: }) do
            header(class: "site-header") do
              div(class: "site-header-container") do
                link_to(root_path, class: "site-logo") do
                  span(class: "logo-icon") { "⚡" }
                  span(class: "logo-text") { "Flash" }
                end

                nav(class: "site-nav") do
                  if current_user.logged_in?
                    link_to("Decks", decks_path, class: "nav-link")
                    link_to("Account", account_path, class: "nav-link")
                    link_to("Subscription", subscription_path, class: "nav-link")
                    span(class: "nav-user") { current_user.email }
                    button_to("Log Out", session_path, method: :delete, class: "nav-logout")
                  else
                    link_to("Log In", new_session_path, class: "nav-link nav-link-primary")
                    link_to("Sign Up", new_account_path, class: "nav-link nav-link-secondary")
                  end
                end
              end
            end

            div(class: "flashes") do
              flash.each do |type, message|
                div(class: "flash-#{type}") { message }
              end
            end

            main(class: "site-main") do
              yield
            end

            footer(class: "site-footer") do
              div(class: "site-footer-container") do
                div(class: "footer-section footer-brand") do
                  div(class: "footer-logo") do
                    span(class: "logo-icon") { "⚡" }
                    span { "Flash" }
                  end
                  p(class: "footer-tagline") do
                    "Master any subject through spaced repetition and intelligent learning algorithms."
                  end
                end

                div(class: "footer-section") do
                  h3(class: "footer-heading") { "Product" }
                  ul(class: "footer-links") do
                    li { link_to("Home", root_path) }
                    li { link_to("Pricing", pricing_path) }
                    if current_user.logged_in?
                      li { link_to("My Decks", decks_path) }
                      li { link_to("Account Settings", account_path) }
                    end
                  end
                end

                div(class: "footer-section") do
                  h3(class: "footer-heading") { "Support" }
                  ul(class: "footer-links") do
                    li { mail_to("support+flash@boon.gl", "Contact Support") }
                    li { link_to("GitHub", repo_url, target: "_blank", rel: "noopener") }
                  end
                end

                div(class: "footer-section") do
                  h3(class: "footer-heading") { "Legal" }
                  ul(class: "footer-links") do
                    li { link_to("Privacy Policy", privacy_path) }
                    li { link_to("Terms of Service", terms_path) }
                  end
                end
              end

              div(class: "footer-bottom") do
                p { "© #{Time.current.year} Flash. All rights reserved." }
              end
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
