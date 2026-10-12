# frozen_string_literal: true

module Components
  # A link to where a source came from, when it has one, and its license.
  class SourceCredit < Components::Base
    attr_accessor :source

    def initialize(source:)
      super()
      self.source = source
    end

    def view_template
      url = source.source_url
      if url.present?
        a(href: url, target: "_blank", rel: "noopener") { "Source" }
        plain(" · ")
      end
      render(SourceLicense.new(source:))
    end
  end
end
