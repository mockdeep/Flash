# frozen_string_literal: true

require "rails_helper"

RSpec.describe SourcesController do
  def login_admin
    create(:user, :admin).tap { |admin| login_as(admin) }
  end

  def own_source(admin, **)
    create(:source, word_list: create(:word_list, user: admin), **)
  end

  def finished_snippet(source, **)
    create(:snippet, :finished, word_list: source.word_list, **)
  end

  def source_params(title: "孔乙己", language: "zh")
    {
      source: {
        title:,
        language:,
        author: "鲁迅",
        source_url: "https://zh.wikisource.org/",
        license: "public_domain",
      },
    }
  end

  describe "#index" do
    it "requires authentication" do
      get(sources_path)

      expect(response).to redirect_to(new_session_path)
    end

    it "is not found for a user who is not an admin" do
      login_as(default_user)

      get(sources_path)

      expect(response).to have_http_status(:not_found)
    end

    it "links to each of the admin's sources" do
      source = own_source(login_admin, title: "孔乙己")

      get(sources_path)

      expect(rendered).to have_link("孔乙己", href: source_path(source))
    end

    it "shows each source's state" do
      own_source(login_admin)

      get(sources_path)

      expect(rendered).to have_css("td", text: "New")
    end

    it "offers to study a source with a finished snippet" do
      finished_snippet(own_source(login_admin))

      get(sources_path)

      expect(rendered).to have_button("Study this list")
    end

    it "offers nothing to study before a snippet is finished" do
      own_source(login_admin)

      get(sources_path)

      expect(rendered).to have_no_button("Study this list")
    end

    it "leaves out another user's sources" do
      create(:source)
      login_admin

      get(sources_path)

      expect(rendered).to have_text("No sources yet")
    end
  end

  describe "#show" do
    it "is not found for a user who is not an admin" do
      login_as(default_user)

      get(source_path(create(:source)))

      expect(response).to have_http_status(:not_found)
    end

    it "is not found for another user's source" do
      login_admin

      get(source_path(create(:source)))

      expect(response).to have_http_status(:not_found)
    end

    it "shows the source's author" do
      source = own_source(login_admin, author: "鲁迅")

      get(source_path(source))

      expect(rendered).to have_text("鲁迅")
    end

    it "credits the source's license" do
      source = own_source(login_admin, license: "public_domain")

      get(source_path(source))

      expect(rendered).to have_text("Public domain")
    end

    it "lists the snippets by heading" do
      source = own_source(login_admin)
      create(:snippet, word_list: source.word_list, heading: "习俗")

      get(source_path(source))

      expect(rendered).to have_css("td", text: "习俗")
    end

    it "says when there are no snippets yet" do
      source = own_source(login_admin)

      get(source_path(source))

      expect(rendered).to have_text("No snippets yet")
    end

    it "offers to add a snippet" do
      source = own_source(login_admin)

      get(source_path(source))

      expect(rendered)
        .to have_link("Add a snippet", href: new_source_snippet_path(source))
    end

    it "offers to study a source with a finished snippet" do
      source = own_source(login_admin)
      finished_snippet(source)

      get(source_path(source))

      expect(rendered).to have_button("Study this list")
    end

    it "offers to share a source with a finished snippet" do
      source = own_source(login_admin)
      finished_snippet(source)

      get(source_path(source))

      expect(rendered).to have_link("Share", href: source_readers_path(source))
    end

    it "offers nothing to share before a snippet is finished" do
      source = own_source(login_admin)
      create(:snippet, word_list: source.word_list)

      get(source_path(source))

      expect(rendered).to have_no_link("Share")
    end
  end

  describe "#new" do
    it "is not found for a user who is not an admin" do
      login_as(default_user)

      get(new_source_path)

      expect(response).to have_http_status(:not_found)
    end

    it "starts on the license that shares with nobody" do
      login_admin

      get(new_source_path)

      expect(rendered)
        .to have_select("License", selected: "All rights reserved")
    end
  end

  describe "#create" do
    it "is not found for a user who is not an admin" do
      login_as(default_user)

      post(sources_path, params: source_params)

      expect(response).to have_http_status(:not_found)
    end

    it "creates the source" do
      login_admin

      expect { post(sources_path, params: source_params) }
        .to change(Source, :count).by(1)
    end

    it "saves its details" do
      login_admin

      post(sources_path, params: source_params)

      expect(Source.last)
        .to have_attributes(source_params[:source].except(:language))
    end

    it "makes its list in the language chosen" do
      login_admin

      post(sources_path, params: source_params(language: "pt"))

      expect(Source.last.word_list.language).to eq("pt")
    end

    it "redirects to the source" do
      login_admin

      post(sources_path, params: source_params)

      expect(response).to redirect_to(source_path(Source.last))
    end

    it "renders the form again with the errors" do
      login_admin

      post(sources_path, params: source_params(title: ""))

      expect(rendered).to have_text("Title can't be blank")
    end

    it "keeps what was typed" do
      login_admin

      post(sources_path, params: source_params(title: ""))

      expect(rendered).to have_field("Author", with: "鲁迅")
    end

    it "keeps the license chosen" do
      login_admin

      post(sources_path, params: source_params(title: ""))

      expect(rendered).to have_select("License", selected: "Public domain")
    end
  end
end
