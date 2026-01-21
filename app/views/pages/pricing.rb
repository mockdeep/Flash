# frozen_string_literal: true

module Views
  module Pages
    class Pricing < Views::Base
      def view_template
        div(class: "pricing-page") do
          div(class: "pricing-header") do
            h1(class: "pricing-title") { "Pricing" }
          end

          div(class: "pricing-plans") do
            # Free plan
            div(class: "pricing-plan") do
              div(class: "plan-header") do
                h2(class: "plan-name") { "Free" }
                div(class: "plan-price") do
                  span(class: "price-currency") { "$" }
                  span(class: "price-value") { "0" }
                  span(class: "price-period") { "/month" }
                end
              end

              div(class: "plan-description") do
                p { "Full access to all features. No credit card required." }
              end

              ul(class: "plan-features") do
                li do
                  span(class: "feature-icon") { "✓" }
                  plain(" Unlimited flashcard decks")
                end
                li do
                  span(class: "feature-icon") { "✓" }
                  plain(" Spaced repetition algorithm")
                end
                li do
                  span(class: "feature-icon") { "✓" }
                  plain(" CSV import")
                end
                li do
                  span(class: "feature-icon") { "✓" }
                  plain(" Progress tracking")
                end
                li do
                  span(class: "feature-icon") { "✓" }
                  plain(" Multiple-choice quizzes")
                end
              end

              if current_user.logged_in?
                link_to("Current Plan", decks_path, class: "plan-button plan-button-current")
              else
                link_to("Get Started", new_account_path, class: "plan-button plan-button-primary")
              end
            end

            # Supporter plan
            div(class: "pricing-plan pricing-plan-featured") do
              div(class: "plan-badge") { "Support the Project" }

              div(class: "plan-header") do
                h2(class: "plan-name") { "Supporter" }
                div(class: "plan-price") do
                  span(class: "price-currency") { "$" }
                  span(class: "price-value") { "5" }
                  span(class: "price-period") { "/month" }
                end
              end

              div(class: "plan-description") do
                p do
                  <<~TEXT
                    Help keep Flash running.
                  TEXT
                end
              end

              div(class: "plan-honesty") do
                div(class: "honesty-icon") { "💛" }
                div(class: "honesty-content") do
                  h3 { "Full transparency" }
                  p do
                    <<~TEXT
                      There are currently no extra benefits or features included with this plan.
                      Your subscription goes directly toward hosting costs and keeping the service
                      running for everyone.
                    TEXT
                  end
                end
              end

              ul(class: "plan-features") do
                li do
                  span(class: "feature-icon") { "✓" }
                  plain(" All Free plan features")
                end
                li do
                  span(class: "feature-icon") { "💛" }
                  plain(" Help cover hosting costs")
                end
                li do
                  span(class: "feature-icon") { "💛" }
                  plain(" Feel good about learning")
                end
              end

              if current_user.logged_in?
                link_to("Subscribe", subscription_path, class: "plan-button plan-button-primary")
              else
                link_to("Sign Up to Subscribe", new_account_path, class: "plan-button plan-button-primary")
              end
            end
          end

          div(class: "pricing-faq") do
            h2(class: "faq-title") { "Frequently Asked Questions" }

            div(class: "faq-grid") do
              div(class: "faq-item") do
                h3(class: "faq-question") { "What do I get with a subscription?" }
                p(class: "faq-answer") do
                  <<~TEXT
                    Currently, nothing extra beyond what the free plan offers! Flash is
                    fully functional without a subscription.
                  TEXT
                end
              end

              div(class: "faq-item") do
                h3(class: "faq-question") { "Why would I subscribe then?" }
                p(class: "faq-answer") do
                  <<~TEXT
                    If Flash helps you learn and you want to ensure it stays available for
                    everyone, your subscription covers hosting costs and helps maintain the
                    service. Think of it as a voluntary "thank you" that keeps the lights on.
                  TEXT
                end
              end

              div(class: "faq-item") do
                h3(class: "faq-question") { "Can I cancel anytime?" }
                p(class: "faq-answer") do
                  <<~TEXT
                    Yes! Cancel from your subscription page with one click. No hassles, no
                    questions asked. You'll keep access until the end of your billing period.
                  TEXT
                end
              end

              div(class: "faq-item") do
                h3(class: "faq-question") { "Is my payment information secure?" }
                p(class: "faq-answer") do
                  plain("Yes. We use ")
                  link_to("Creem", "https://creem.io", target: "_blank", rel: "noopener noreferrer")
                  plain(<<~TEXT)
                     for payment processing. We never see or store your credit card
                    information. All payments are encrypted and secured.
                  TEXT
                end
              end

              div(class: "faq-item") do
                h3(class: "faq-question") { "What if I need help?" }
                p(class: "faq-answer") do
                  plain("Email us anytime at ")
                  mail_to("support+flash@boon.gl")
                  plain(<<~TEXT)
                    . We typically respond within 24 hours and are happy to help with
                    any questions or issues.
                  TEXT
                end
              end

              div(class: "faq-item") do
                h3(class: "faq-question") { "Will there be premium features later?" }
                p(class: "faq-answer") do
                  <<~TEXT
                    Maybe! If we do add premium features in the future, early supporters will
                    be the first to know. For now, we're focused on making the core experience
                    excellent for everyone.
                  TEXT
                end
              end
            end
          end
        end
      end
    end
  end
end
