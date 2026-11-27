# frozen_string_literal: true

module Components
  # A Read-tab page's Back and Next links, with the arrow keys, around its
  # count. Each link opens its page in the reading frame.
  class ReadingPageLinks < Components::Base
    def initialize(deck:, pages:, page:)
      super()
      @deck = deck
      @pages = pages
      @page = page
    end

    def view_template
      nav(class: "reading-pages", aria: { label: "Pages" }) do
        page_link("← Back", @page.number - 1, "ArrowLeft")
        span(class: "reading-pages__count") do
          "Page #{@page.number} of #{@pages.size}"
        end
        page_link("Next →", @page.number + 1, "ArrowRight")
      end
    end

    private

    # A missing neighbor keeps its place, so the count stays centered.
    def page_link(label, number, hotkey)
      neighbor = @pages.page(number)
      return span(class: "reading-pages__link") unless neighbor

      link_to(
        label,
        path_to(neighbor.start),
        class: "#{button_class(:compact, :secondary)} reading-pages__link",
        data: { hotkeys_target: "click", hotkey: },
      )
    end

    def path_to(start)
      deck_reading_path(@deck, sentence: start.sentence_id, token: start.index)
    end
  end
end
