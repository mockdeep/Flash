# frozen_string_literal: true

module Components
  # What tapping a chip or node on the reading map opens: the list's name,
  # how much of it the learner knows and how many words are new, the nodes
  # its lines lead to with what studying it would gain them there, and a
  # button to start it or carry on.
  class MapPopover < Components::Base
    attr_accessor :id, :node, :leads

    def initialize(id:, node:, leads:)
      super()
      self.id = id
      self.node = node
      self.leads = leads
    end

    def view_template
      div(id:, popover: true, class: "reading-map__popover") do
        render_name
        p(class: "reading-map__numbers") { numbers }
        render_leads if leads.any?
        render_button
      end
    end

    private

    def render_name
      h2(class: "reading-map__popover-name") do
        plain(node.word_list.name)
        translation(node.word_list.source&.title_translation)
      end
    end

    def numbers
      heat = node.heat

      "#{heat.percent}% known · #{pluralize(heat.new_words, "new word")}"
    end

    def render_leads
      p(class: "reading-map__leads-label") { "Leads to" }
      ul(class: "reading-map__leads") do
        leads.each do |other, gains|
          li { "#{other.word_list.name} · #{gains.percent}% of its words" }
        end
      end
    end

    def render_button
      look = button_class(:compact, :primary)
      return render_start(look) unless node.started?

      link_to("Continue", deck_study_path(node.continue_deck), class: look)
    end

    def render_start(look)
      button_to("Start", word_list_deck_path(node.word_list), class: look)
    end
  end
end
