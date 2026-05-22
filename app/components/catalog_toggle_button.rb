# frozen_string_literal: true

module Components
  class CatalogToggleButton < Components::Base
    attr_accessor :deck

    def initialize(deck:)
      super()
      self.deck = deck
    end

    def view_template
      deck.publicly_visible? ? render_remove_button : render_add_button
    end

    private

    def render_add_button
      button_to(
        "Add to Catalog",
        deck_catalog_listing_path(deck),
        method: :post,
        class: button_class(:secondary, :compact),
      )
    end

    def render_remove_button
      confirm = t("catalog_listings.destroy.confirm")
      button_to(
        "Remove from Catalog",
        deck_catalog_listing_path(deck),
        method: :delete,
        class: button_class(:ghost, :compact),
        form: { data: { turbo_confirm: confirm } },
      )
    end
  end
end
