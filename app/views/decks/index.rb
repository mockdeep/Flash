# frozen_string_literal: true

module Views
  module Decks
    class Index < Views::Base
      include Phlex::Rails::Helpers::TimeAgoInWords

      attr_accessor :decks

      def initialize(decks:)
        super()
        self.decks = decks
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

          if decks.empty?
            render_empty_state
          else
            render_deck_sections
          end
        end
      end

      private

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

        topics.each do |topic|
          render_topic_section(topic.name, grouped[topic], "topic-#{topic.id}")
        end
        return if loose.empty?

        render_topic_section(topics.any? ? "Other Decks" : nil, loose, "other")
      end

      # The filter key names the remembered tab in localStorage, so it has to
      # stay stable across visits, not across users -- localStorage is already
      # per-browser.
      def render_topic_section(title, section_decks, section_id)
        section(
          class: "topic-section",
          data: {
            controller: "filter rail",
            filter_key_value: section_id,
            filter_active_class: "rail-tab--active",
            action: "resize@window->rail#syncArrows " \
                    "filter:applied->rail#syncArrows",
          },
        ) do
          render_section_heading(title, section_decks) if title
          render_rail_tabs(section_decks)
          render_rail_wrap(section_decks)
        end
      end

      def render_rail_tabs(section_decks)
        labels = type_labels(section_decks)
        return if labels.size < 2

        div(class: "rail-tabs") do
          render_rail_tab("All", section_decks.size, active: true)
          labels.each do |label|
            count = section_decks.count { |deck| deck.type_label == label }
            render_rail_tab(label, count)
          end
        end
      end

      def type_labels(section_decks)
        section_decks.map(&:type_label).uniq.sort
      end

      def render_rail_tab(label, count, active: false)
        classes = ["rail-tab", ("rail-tab--active" if active)].compact.join(" ")
        button(
          type: "button",
          class: classes,
          data: {
            action: "filter#select",
            filter_value_param: label,
            filter_target: "tab",
          },
        ) do
          plain(label)
          span(class: "rail-tab-count") { count }
        end
      end

      def render_rail_wrap(section_decks)
        div(class: "rail-wrap") do
          render_rail_arrow(-1, "‹", "Scroll left")
          render_rail(section_decks)
          render_rail_arrow(1, "›", "Scroll right")
        end
      end

      def render_rail_arrow(direction, glyph, label)
        side = direction.negative? ? "left" : "right"
        button(
          type: "button",
          class: "rail-arrow rail-arrow--#{side}",
          aria: { label: },
          data: {
            action: "rail#scroll",
            rail_dir_param: direction,
            rail_target: "#{side}Arrow",
          },
          hidden: true,
        ) { glyph }
      end

      def render_section_heading(title, section_decks)
        h2(class: "decks-section-title") do
          plain(title)
          span(class: "topic-meta") do
            pluralize(section_decks.size, "deck")
          end
        end
      end

      # The most recently studied deck repeats at the head of the rail as a
      # spotlight; the copy in its natural slot stays put so the list order
      # never shifts underneath the reader.
      def render_rail(section_decks)
        div(
          class: "rail",
          data: { rail_target: "rail", action: "scroll->rail#syncArrows" },
        ) do
          render_mru_spotlight(section_decks)

          deck_sets(section_decks).each_with_index do |set_decks, set_index|
            set_decks.each_with_index do |deck, deck_index|
              set_start = set_index.positive? && deck_index.zero?
              render_rail_card(deck, set_start:)
            end
          end
        end
      end

      # Decks sharing a data_set render as one rail card. Nothing creates a
      # second deck over a set today, so this groups sets of one - it stays
      # because sharing by reference will make sets real again.
      def deck_sets(section_decks)
        section_decks
          .sort_by(&:name)
          .chunk_while do |a, b|
            a.data_set_id.present? && a.data_set_id == b.data_set_id
          end
      end

      # The divider carries the spotlight deck's type so the two hide together
      # when a tab filters that type out.
      def render_mru_spotlight(section_decks)
        mru = section_decks.select(&:last_studied_at).max_by(&:last_studied_at)
        return if mru.nil?

        render_rail_card(mru, mru: true)
        div(
          class: "rail-divider",
          data: { filter_value: mru.type_label, filter_target: "item" },
        )
      end

      def render_rail_card(deck, mru: false, set_start: false)
        classes = [
          "rail-card",
          ("rail-card--mru" if mru),
          ("rail-card--set-start" if set_start),
        ].compact.join(" ")

        div(
          class: classes,
          data: { filter_value: deck.type_label, filter_target: "item" },
        ) do
          remaining = deck.cards.not_done(deck.level).count
          render_study_link(deck, remaining)
          render_mru_label(deck) if mru
          div(class: "rail-type") { deck.type_label }
          render_rail_title(deck)
          render(Components::LevelProgress.new(deck:))
          render_rail_meta(deck, remaining)
        end
      end

      def render_study_link(deck, remaining)
        return if deck.cards.none?

        label = remaining.zero? ? "Review →" : "Study →"
        link_to(label, deck_study_path(deck), class: "rail-card-study")
      end

      def render_mru_label(deck)
        div(class: "mru-label") do
          "↻ Last studied #{time_ago_in_words(deck.last_studied_at)} ago"
        end
      end

      # Language decks title with the data_set's base name (a reverse deck
      # drops its "(reversed)" suffix on the shared rail card).
      def render_rail_title(deck)
        h3(class: "rail-title") do
          link_to(deck.data_set&.name || deck.name, deck_path(deck))
          catalog_badge if deck.publicly_visible?
        end
      end

      def render_rail_meta(deck, remaining)
        div(class: "rail-meta") { render_remaining(deck, remaining) }
      end

      def render_remaining(deck, remaining)
        if deck.cards.none?
          span(class: "rail-remaining rail-remaining--empty") { "No cards yet" }
        elsif remaining.zero?
          span(class: "rail-remaining rail-remaining--done") { "Done ✓" }
        else
          span(class: "rail-remaining") { "#{remaining} left" }
        end
      end
    end
  end
end
