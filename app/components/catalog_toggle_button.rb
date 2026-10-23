# frozen_string_literal: true

module Components
  # Adds a deck or a source to the catalog, or takes it out, through its
  # listing route.
  class CatalogToggleButton < Components::Base
    attr_accessor :listed, :path, :confirm

    def initialize(listed:, path:, confirm:)
      super()
      self.listed = listed
      self.path = path
      self.confirm = confirm
    end

    def view_template
      listed ? render_remove_button : render_add_button
    end

    private

    def render_add_button
      button_to(
        "Add to Catalog",
        path,
        method: :post,
        class: button_class(:secondary, :compact),
      )
    end

    def render_remove_button
      button_to(
        "Remove from Catalog",
        path,
        method: :delete,
        class: button_class(:ghost, :compact),
        form: { data: { turbo_confirm: confirm } },
      )
    end
  end
end
