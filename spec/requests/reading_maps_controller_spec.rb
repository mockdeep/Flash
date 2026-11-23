# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReadingMapsController do
  def login_admin
    create(:user, :admin).tap { |admin| login_as(admin) }
  end

  def list_on_map(**)
    list = create(:word_list, visibility: "public", angle: 90, **)
    create(:sense_membership, word_list: list)
    list
  end

  def level_list(level, name)
    list_on_map(curriculum: true, level:, angle: nil, name:)
  end

  def source_on_map(**)
    source = create(:source, word_list: list_on_map, **)
    create(:snippet, :finished, source:)
  end

  def linked_lists
    word_list = list_on_map
    linked_word_list = list_on_map

    create(:word_list_link, word_list:, linked_word_list:)
  end

  describe "#show" do
    it "is not found for a member" do
      login_as(default_user)
      list_on_map

      get(reading_map_path("mandarin"))

      expect(response).to have_http_status(:not_found)
    end

    it "is not found for a language with no word lists" do
      login_admin

      get(reading_map_path("klingon"))

      expect(response).to have_http_status(:not_found)
    end

    it "is headed by the language's name" do
      login_admin
      list_on_map

      get(reading_map_path("mandarin"))

      expect(rendered).to have_css("h1", text: "Mandarin")
    end

    it "shows a list as a button" do
      login_admin
      list_on_map(name: "Story")

      get(reading_map_path("mandarin"))

      expect(rendered).to have_button("Story")
    end

    it "shows a list's heat" do
      login_admin
      list_on_map

      get(reading_map_path("mandarin"))

      expect(rendered).to have_css(".reading-map__node", text: "0%")
    end

    it "places a list from its ring and angle" do
      login_admin
      list_on_map

      get(reading_map_path("mandarin"))

      expect(rendered.find(".reading-map__node")[:style])
        .to eq("--across: 50.0; --down: 50.0; --heat: 0")
    end

    it "draws a list with no source as a square" do
      login_admin
      list_on_map

      get(reading_map_path("mandarin"))

      expect(rendered).to have_css(".reading-map__node--list")
    end

    it "draws a source as a circle" do
      login_admin
      create(:snippet, :finished, word_list: list_on_map)

      get(reading_map_path("mandarin"))

      expect(rendered).to have_no_css(".reading-map__node--list")
    end

    it "draws a private list hollow" do
      admin = login_admin
      list = list_on_map(visibility: "private", user: admin)
      create(:snippet, :finished, word_list: list)

      get(reading_map_path("mandarin"))

      expect(rendered).to have_css(".reading-map__node--private")
    end

    it "marks the node the map opens on" do
      login_admin
      list_on_map(name: "Story")

      get(reading_map_path("mandarin"))

      expect(rendered)
        .to have_css("[data-reading-map-target='start']", text: "Story")
    end

    it "marks no node off center as the one the map opens on" do
      login_admin
      list_on_map(angle: 40)

      get(reading_map_path("mandarin"))

      expect(rendered).to have_no_css("[data-reading-map-target='start']")
    end

    it "has a button to zoom in, on the + key" do
      login_admin
      list_on_map

      get(reading_map_path("mandarin"))

      expect(rendered.find_button("Zoom in")["data-hotkey"]).to eq("+")
    end

    it "has a button to zoom out" do
      login_admin
      list_on_map

      get(reading_map_path("mandarin"))

      expect(rendered.find_button("Zoom out")["data-action"])
        .to eq("reading-map#zoomOut")
    end

    it "has a button to recenter the map" do
      login_admin
      list_on_map

      get(reading_map_path("mandarin"))

      expect(rendered).to have_button("Recenter")
    end

    it "marks a list the learner has a deck for" do
      admin = login_admin
      create(:reading_deck, word_list: list_on_map, user: admin)

      get(reading_map_path("mandarin"))

      expect(rendered).to have_css(".reading-map__node.reading-map__started")
    end

    it "leaves a list with no deck unmarked" do
      login_admin
      list_on_map

      get(reading_map_path("mandarin"))

      expect(rendered).to have_no_css(".reading-map__started")
    end

    it "ticks a list whose goal is met today" do
      admin = login_admin
      deck = create(:reading_deck, word_list: list_on_map, user: admin)
      deck.study_days.create!(studied_on: Date.current, completed_count: 50)

      get(reading_map_path("mandarin"))

      expect(rendered).to have_css(".reading-map__tick", text: "✓")
    end

    it "leaves a list still short of its goal unticked" do
      admin = login_admin
      create(:reading_deck, word_list: list_on_map, user: admin)

      get(reading_map_path("mandarin"))

      expect(rendered).to have_no_css(".reading-map__tick")
    end

    it "opens on a started chip" do
      admin = login_admin
      create(:reading_deck, word_list: level_list(1, "Tale A1"), user: admin)

      get(reading_map_path("mandarin"))

      expect(rendered)
        .to have_css(".reading-map__chip[data-reading-map-target='start']")
    end

    it "opens a list's popover from its button" do
      login_admin
      list = list_on_map

      get(reading_map_path("mandarin"))

      expect(rendered.find(".reading-map__node")[:popovertarget])
        .to eq("map-list-#{list.id}")
    end

    it "names the list in its popover" do
      login_admin
      list_on_map(name: "Story")

      get(reading_map_path("mandarin"))

      expect(rendered).to have_css(".reading-map__popover h2", text: "Story")
    end

    it "translates a source's title in its popover" do
      login_admin
      source_on_map(title_translation: "Spring")

      get(reading_map_path("mandarin"))

      expect(rendered)
        .to have_css(".reading-map__popover .translation", text: "Spring")
    end

    it "says how much of a list is known and how many words are new" do
      login_admin
      list_on_map

      get(reading_map_path("mandarin"))

      expect(rendered)
        .to have_css(".reading-map__numbers", text: "0% known · 1 new word")
    end

    it "says where a list's line leads and what it gains there" do
      login_admin
      linked_lists.linked_word_list.update!(name: "Further")

      get(reading_map_path("mandarin"))

      expect(rendered)
        .to have_css(".reading-map__leads", text: "Further · 0% of its words")
    end

    it "leaves out where a list leads when it has no lines" do
      login_admin
      list_on_map

      get(reading_map_path("mandarin"))

      expect(rendered).to have_no_css(".reading-map__leads")
    end

    it "offers to start a list the learner has no deck for" do
      login_admin
      list = list_on_map

      get(reading_map_path("mandarin"))

      expect(rendered.find("form:has(button)", text: "Start")[:action])
        .to eq(word_list_deck_path(list))
    end

    it "offers to continue a list the learner has a deck for" do
      admin = login_admin
      deck = create(:reading_deck, word_list: list_on_map, user: admin)

      get(reading_map_path("mandarin"))

      expect(rendered).to have_link("Continue", href: deck_study_path(deck))
    end

    it "shows a level's chip without what the level names share" do
      login_admin
      level_list(1, "Tale A1")
      level_list(2, "Tale A2")

      get(reading_map_path("mandarin"))

      expect(rendered).to have_css(".reading-map__chip", text: "A2")
    end

    it "keeps the word before a chip's bare number" do
      login_admin
      level_list(1, "HSK Level 1")
      level_list(2, "HSK Level 2")

      get(reading_map_path("mandarin"))

      expect(rendered).to have_css(".reading-map__chip", text: "Level 2")
    end

    it "draws a line for each level" do
      login_admin
      level_list(1, "Tale A1")
      level_list(2, "Tale A2")

      get(reading_map_path("mandarin"))

      expect(rendered).to have_css(".reading-map__line", count: 2)
    end

    it "draws the line between two linked lists" do
      login_admin
      linked_lists

      get(reading_map_path("mandarin"))

      expect(rendered.find(".reading-map__link")[:style])
        .to eq("--strength: 0.5")
    end
  end
end
