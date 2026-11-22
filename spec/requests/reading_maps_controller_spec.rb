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
