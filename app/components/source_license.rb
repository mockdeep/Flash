# frozen_string_literal: true

module Components
  # A source's license by name, linked to its terms when it has them.
  class SourceLicense < Components::Base
    attr_accessor :source

    def initialize(source:)
      super()
      self.source = source
    end

    def view_template
      url = source.license_url
      return plain(source.license_name) unless url

      a(href: url, target: "_blank", rel: "noopener") { source.license_name }
    end
  end
end
