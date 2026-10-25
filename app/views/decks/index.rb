# frozen_string_literal: true

module Views
  module Decks
    class Index < Views::Base
      include Phlex::Rails::Helpers::TimeAgoInWords

      def view_template
        div(class: "decks-container") do
          div(class: "decks-header") do
            h1(class: "decks-title") { "Your Decks" }
            div(class: "decks-header-actions") do
              link_to("Browse Catalog", catalog_index_path, class: button_class(:ghost))
              link_to("+ Create New Deck", new_deck_path, class: button_class(:primary))
            end
          end

          if current_user.decks.none?
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

      def render_deck_sections
        DeckSection.for(current_user.decks).each do |deck_section|
          render(Components::DeckRail.new(deck_section:)) do
            render_rail(deck_section.decks.ordered.with_progress)
          end
        end
      end

      # The featured deck repeats at the head of the rail; the copy in its
      # natural slot stays put so the list order never shifts underneath the
      # reader.
      def render_rail(section_decks)
        render_featured(section_decks)

        unmet_ids = section_decks.goal_unmet_today.ids
        section_decks.chunk_while { |a, b| same_list?(a, b) }.each do |decks|
          render_rail_card(card_deck(decks, unmet_ids))
        end
      end

      def same_list?(deck, other)
        deck.word_list_id.present? && deck.word_list_id == other.word_list_id
      end

      # A source's decks (one per section) share a card, which opens the
      # same deck Next Deck would, else the one last studied.
      def card_deck(decks, unmet_ids)
        decks.find { unmet_ids.include?(it.id) } ||
          decks.select(&:last_studied_at).max_by(&:last_studied_at) ||
          decks.first
      end

      # Same order as DeckSection#first_unmet, so the milestone's Next Deck
      # and the featured deck agree.
      def render_featured(section_decks)
        unmet =
          section_decks.goal_unmet_today.find { !it.waiting_for_tomorrow? }
        return render_featured_card(unmet, "→ Up next") if unmet

        recent = section_decks.recently_studied.first
        return if recent.nil?

        ago = time_ago_in_words(recent.last_studied_at)
        render_featured_card(recent, "↻ Last studied #{ago} ago")
      end

      def render_featured_card(deck, label)
        render_rail_card(deck, featured_label: label)
        div(class: "rail-divider")
      end

      def render_rail_card(deck, featured_label: nil)
        classes = ["rail-card", ("rail-card--featured" if featured_label)]

        div(class: classes.compact.join(" ")) do
          div(class: "featured-label") { featured_label } if featured_label
          div(class: "rail-type") { deck.type_label }
          render_rail_title(deck, featured: featured_label.present?)
          render(Components::RoundProgress.new(deck:))
          render_rail_meta(deck, deck.remaining_count)
        end
      end

      # A source's card is named for the source, whichever section it opens;
      # the featured card names the section.
      def render_rail_title(deck, featured:)
        name, name_translation =
          if deck.snippet && !featured
            [deck.word_list.name, deck.source.title_translation]
          else
            [deck.name, deck.name_translation]
          end

        h3(class: "rail-title") do
          link_to(name, deck_study_path(deck))
          catalog_badge if deck.publicly_visible?
          translation(name_translation)
        end
      end

      def render_rail_meta(deck, remaining)
        div(class: "rail-meta") { render_remaining(deck, remaining) }
      end

      def render_remaining(deck, remaining)
        total = deck.cards_count
        if total.zero?
          span(class: "rail-remaining rail-remaining--empty") { "No cards yet" }
        elsif remaining.zero?
          span(class: "rail-remaining rail-remaining--done") do
            "All #{total} done ✓"
          end
        else
          span(class: "rail-remaining") do
            plain(remaining)
            span(class: "rail-remaining__total") { " of #{total} left" }
          end
        end
      end
    end
  end
end
