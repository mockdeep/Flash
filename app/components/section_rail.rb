# frozen_string_literal: true

module Components
  # A section's decks as a rail of cards under its heading: the deck Next
  # Deck would pick there (else the one last studied) featured first, then
  # every deck in order.
  class SectionRail < Components::Base
    include Phlex::Rails::Helpers::TimeAgoInWords

    attr_accessor :deck_section

    def initialize(deck_section:)
      super()
      self.deck_section = deck_section
    end

    def view_template
      render(Components::DeckRail.new(deck_section:, map_path:)) { render_rail }
    end

    private

    # A language has a reading map; Basic and Music don't.
    def map_path
      section_decks_path(deck_section.anchor) if deck_section.language
    end

    # The featured deck repeats at the head of the rail; the copy in its
    # natural slot stays put so the list order never shifts underneath the
    # reader. The decks load once, since counting their cards is the
    # page's heaviest query.
    def render_rail
      section_decks = deck_section.decks.ordered.with_progress.to_a
      render_featured(section_decks, deck_section.first_unmet)
      heats = heats_for(section_decks)

      section_decks.each do |deck|
        render_rail_card(deck, heat: heats[deck.word_list_id])
      end
    end

    def heats_for(section_decks)
      Heat.for(current_user, section_decks.filter_map(&:word_list_id))
    end

    def last_studied(decks)
      decks.select(&:last_studied_at).max_by(&:last_studied_at)
    end

    # The deck the milestone's Next Deck would pick here, so the two
    # agree; shown from the decks loaded with their card counts.
    def render_featured(section_decks, next_deck)
      unmet = section_decks.find { it.id == next_deck&.id }
      return render_featured_card(unmet, "→ Up next") if unmet

      recent = last_studied(section_decks)
      return if recent.nil?

      ago = time_ago_in_words(recent.last_studied_at)
      render_featured_card(recent, "↻ Last studied #{ago} ago")
    end

    def render_featured_card(deck, label)
      render_rail_card(deck, featured_label: label)
      div(class: "rail-divider")
    end

    def render_rail_card(deck, featured_label: nil, heat: nil)
      classes = ["rail-card", ("rail-card--featured" if featured_label)]

      div(class: classes.compact.join(" ")) do
        div(class: "featured-label") { featured_label } if featured_label
        div(class: "rail-type") { deck.type_label }
        render_rail_title(deck)
        render(Components::RoundProgress.new(deck:))
        render_rail_meta(deck, deck.remaining_count, heat)
      end
    end

    def render_rail_title(deck)
      h3(class: "rail-title") do
        link_to(deck.name, deck_study_path(deck))
        catalog_badge if deck.publicly_visible?
        translation(deck.name_translation)
      end
    end

    def render_rail_meta(deck, remaining, heat)
      div(class: "rail-meta") do
        render_remaining(deck, remaining)
        span(class: "rail-heat") { "#{heat.percent}% known" } if heat
      end
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
