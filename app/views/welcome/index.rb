# frozen_string_literal: true

module Views
  module Welcome
    class Index < Views::Base
      def view_template
        div(class: "welcome-hero") do
          header(class: "welcome-header") do
            h1(class: "welcome-title") { "Memorize Anything" }
            p(class: "welcome-subtitle") do
              <<~TEXT
                Flash uses spaced repetition and intelligent algorithms to help you
                learn faster and remember longer. Build custom decks, track your
                progress, and transform the way you study.
              TEXT
            end
          end

          div(class: "welcome-cta") do
            link_to("Get Started", new_account_path, class: "btn-primary")
            link_to("Try a Demo", demo_path, class: "btn-secondary")
            link_to("Sign In", new_session_path, class: "btn-secondary")
          end

          div(class: "welcome-screenshot") do
            div(class: "screenshot-card") do
              image_tag("screenshot.png", alt: "Flash application interface showing flashcard study session")
            end
          end

          div(class: "welcome-features") do
            feature_card(
              number: "01",
              title: "Spaced Repetition",
              description: "Our intelligent algorithm presents cards at optimal intervals, maximizing retention and minimizing study time.",
            )

            feature_card(
              number: "02",
              title: "Custom Decks",
              description: "Create unlimited flashcard decks or import from CSV. Organize by topic, category, or subject.",
            )

            feature_card(
              number: "03",
              title: "Progress Tracking",
              description: "Watch your knowledge grow with detailed statistics that adapt your study plan to your learning pace.",
            )
          end
        end
      end

      private

      def feature_card(number:, title:, description:)
        div(class: "feature-card") do
          div(class: "feature-number") { number }
          h3(class: "feature-title") { title }
          p(class: "feature-description") { description }
        end
      end
    end
  end
end
