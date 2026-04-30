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
      include Phlex::Rails::Helpers::LinkToUnlessCurrent
      include Phlex::Rails::Helpers::MailTo
      include Phlex::Rails::Helpers::Flash

      def view_template(&)
        doctype

        html do
          head do
            title { "Flash" }
            meta(name: "viewport", content: "width=device-width, initial-scale=1")
            csrf_meta_tags
            csp_meta_tag

            link(rel: "icon", href: "/favicon.ico", sizes: "any")
            link(rel: "icon", href: "/icon.svg", type: "image/svg+xml")
            link(rel: "apple-touch-icon", href: "/apple-touch-icon.png")
            link(rel: "manifest", href: pwa_manifest_path)
            stylesheet_link_tag("application", media: "all")
            javascript_include_tag("application")
          end

          action = "keydown@document->hotkeys#handleKeydown"
          body(data: { controller: "hotkeys", action: }) do
            header(
              class: "site-header",
              data: { controller: "mobile-nav" },
            ) do
              div(class: "site-header-container") do
                link_to(root_path, class: "site-logo") do
                  span(class: "logo-icon") { "⚡" }
                  span(class: "logo-text") { "Flash" }
                end

                button(
                  class: "nav-hamburger",
                  data: { action: "mobile-nav#toggle" },
                  aria: { label: "Toggle navigation" },
                ) do
                  span(class: "hamburger-line")
                  span(class: "hamburger-line")
                  span(class: "hamburger-line")
                end

                nav(
                  class: "site-nav",
                  data: { mobile_nav_target: "menu" },
                ) do
                  link_to("Catalog", catalog_index_path, class: "nav-link")
                  if current_user.guest?
                    link_to_unless_current("Sign Up", new_account_path, class: "nav-link nav-link-secondary")
                    link_to_unless_current("Log In", new_session_path, class: "nav-link nav-link-primary")
                  elsif current_user.logged_in?
                    link_to("Decks", decks_path, class: "nav-link")
                    link_to("Account", account_path, class: "nav-link")
                    link_to("Subscription", subscription_path, class: "nav-link")
                    span(class: "nav-user") do
                      plain(current_user.username)
                      supporter_badge if current_user.supporter?
                    end
                    button_to("Log Out", session_path, method: :delete, class: "nav-logout")
                  else
                    link_to_unless_current("Log In", new_session_path, class: "nav-link nav-link-primary")
                    link_to_unless_current("Sign Up", new_account_path, class: "nav-link nav-link-secondary")
                  end
                end
              end
            end

            div(class: "flashes") do
              flash.each do |type, message|
                div(class: "flash-#{type}") { message }
              end
            end

            main(class: "site-main", &)

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
                    li { link_to("Catalog", catalog_index_path) }
                    li { link_to("Pricing", pricing_path) }
                    if current_user.logged_in? && !current_user.guest?
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
