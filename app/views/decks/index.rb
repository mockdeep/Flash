# frozen_string_literal: true

module Views
  module Decks
    class Index < Views::Base
      attr_accessor :decks, :pending_counts, :filter_pending

      def initialize(decks:, pending_counts:, filter_pending:)
        super()
        self.decks = decks
        self.pending_counts = pending_counts
        self.filter_pending = filter_pending
      end

      def view_template
        div(class: "decks-container") do
          div(class: "decks-header") do
            h1(class: "decks-title") { "Your Decks" }
            div(class: "decks-header-actions") do
              link_to("Browse Catalog", catalog_index_path, class: button_class(:ghost))
              link_to("+ Create New Deck", new_deck_path, class: button_class(:primary))
            end
          end

          render_filter_chip if pending_counts.any?

          if decks.empty?
            render_empty_state
          else
            render_deck_sections
          end
        end
      end

      private

      def render_filter_chip
        div(class: "decks-filter") do
          filter_pending ? render_active_chip : render_inactive_chip
        end
      end

      def render_active_chip
        link_to(
          "Show all decks",
          decks_path,
          class: "filter-chip filter-chip--active",
        )
      end

      def render_inactive_chip
        link_to(
          "Show only decks with pending suggestions",
          decks_path(filter: "pending_suggestions"),
          class: "filter-chip",
        )
      end

      def render_empty_state
        div(class: "empty-state") do
          div(class: "empty-state-icon") { "📚" }
          h2(class: "empty-state-title") { "No Decks Yet" }
          p(class: "empty-state-text") do
            "Create your first flashcard deck or browse the catalog to get started."
          end
          link_to("Create Your First Deck", new_deck_path, class: button_class(:primary))
        end
      end

      # Topic sections first (alphabetical), then the un-topiced decks -- under
      # an "Other Decks" heading only when there are topics to distinguish
      # them from.
      def render_deck_sections
        grouped = decks.group_by(&:topic)
        topics = grouped.keys.compact.sort_by(&:name)
        loose = grouped[nil] || []

        topics.each { |topic| render_topic_section(topic, grouped[topic]) }
        return if loose.empty?

        h2(class: "decks-section-title") { "Other Decks" } if topics.any?
        render_decks_grid(loose)
      end

      def render_topic_section(topic, topic_decks)
        h2(class: "decks-section-title") { topic.name }
        render_decks_grid(topic_decks)
      end

      def render_decks_grid(section_decks)
        div(class: "decks-grid") do
          section_decks.each do |deck|
            render_deck_card(deck)
          end
        end
      end

      def render_deck_card(deck)
        div(class: "card card--striped deck-card") do
          render_deck_card_header(deck)

          if deck.cards.any?
            render_deck_stats(deck)
          else
            div(class: "deck-empty-message") do
              "No cards yet"
            end
          end

          div(class: "deck-card-actions") do
            link_to("Study", deck_study_path(deck), class: button_class(:secondary, :compact))
            link_to("View Details", deck_path(deck), class: button_class(:ghost, :compact))
          end
        end
      end

      def render_deck_card_header(deck)
        div(class: "deck-card-header") do
          div do
            h3(class: "deck-card-title") do
              plain(deck.name)
              catalog_badge if deck.publicly_visible?
            end
            render_stars(deck.level - 1)
            render_suggestion_badge(deck) if pending_counts[deck.id]&.positive?
          end
          div(class: "card-count") do
            span(class: "count-number") { deck.cards.count }
            span(class: "count-label") { "cards" }
          end
        end
      end

      def render_deck_stats(deck)
        not_done_count = deck.cards.not_done(deck.level).count
        done_count = deck.cards.done(deck.level).count

        div(class: "deck-stats") do
          div(class: "stat-item stat-level") do
            div(class: "stat-value") { deck.level }
            div(class: "stat-label") { "Level" }
          end

          div(class: "stat-item stat-pending") do
            div(class: "stat-value") { not_done_count }
            div(class: "stat-label") { "Remaining" }
          end

          div(class: "stat-item stat-done") do
            div(class: "stat-value") { done_count }
            div(class: "stat-label") { "Done" }
          end
        end
      end

      def render_suggestion_badge(deck)
        link_to(
          "#{pending_counts[deck.id]} pending suggestions",
          deck_suggestions_path(deck),
          class: "deck-suggestion-badge",
        )
      end

      def render_stars(completed_levels)
        div(class: "deck-card-stars") do
          3.times do |i|
            css = i < completed_levels ? "star star--filled" : "star star--empty"
            span(class: css) { "★" }
          end
        end
      end
    end
  end
end
