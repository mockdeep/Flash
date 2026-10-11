# frozen_string_literal: true

module Components
  # A snippet's license by name, linked to its terms when it has them.
  class SnippetLicense < Components::Base
    attr_accessor :snippet

    def initialize(snippet:)
      super()
      self.snippet = snippet
    end

    def view_template
      url = snippet.license_url
      return plain(snippet.license_name) unless url

      a(href: url, target: "_blank", rel: "noopener") { snippet.license_name }
    end
  end
end
