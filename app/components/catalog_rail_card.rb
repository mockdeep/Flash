# frozen_string_literal: true

module Components
  # A public deck's card on the catalog, or a listed source's, which shows
  # through its preview deck and links to the source's own pages.
  class CatalogRailCard < Components::Base
    attr_accessor :deck, :source

    def initialize(deck:, source: nil)
      super()
      self.deck = deck
      self.source = source
    end

    def view_template
      div(class: "rail-card") do
        div(class: "rail-type") { deck.type_label }
        render_title
        render_meta
        member? ? render_owned_link : render_try_button
      end
    end

    private

    def render_title
      h3(class: "rail-title") do
        link_to(deck.name, preview_path)
        music_badge if deck.music?
        texts_badge if deck.shares_texts?
        translation(deck.name_translation)
      end
    end

    def render_meta
      div(class: "rail-meta") do
        span(class: "catalog-rail-owner") do
          plain("by #{deck.user.username}")
          supporter_badge if deck.user.supporter?
        end
        span(class: "catalog-rail-count") do
          pluralize(deck.cards_count, "card")
        end
      end
    end

    def render_owned_link
      own_deck = current_user.deck_for(deck)
      return unless own_deck

      link_to(
        "✓ In your decks",
        deck_study_path(own_deck),
        class: "catalog-rail-owned",
      )
    end

    def render_try_button
      form_with(url: try_path, class: "catalog-rail-try") do |form|
        timezone_field(form)
        form.button("Try This Deck", class: button_class(:primary, :compact))
      end
    end

    def preview_path
      source ? catalog_source_path(source) : catalog_path(deck)
    end

    def try_path
      source ? try_catalog_source_path(source) : try_catalog_path(deck)
    end

    def member? = current_user.logged_in? && !current_user.guest?
  end
end
