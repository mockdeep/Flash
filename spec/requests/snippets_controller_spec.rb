# frozen_string_literal: true

require "rails_helper"

RSpec.describe SnippetsController do
  def login_admin
    create(:user, :admin).tap { |admin| login_as(admin) }
  end

  def own_snippet(admin, **)
    create(:snippet, word_list: create(:word_list, user: admin), **)
  end

  def snippet_params(title: "孔乙己")
    { snippet: { list_name: "Lu Xun", title:, author: "鲁迅", body: "我爱你。" } }
  end

  describe "#index" do
    it "requires authentication" do
      get(snippets_path)

      expect(response).to redirect_to(new_session_path)
    end

    it "is not found for a user who is not an admin" do
      login_as(default_user)

      get(snippets_path)

      expect(response).to have_http_status(:not_found)
    end

    it "lists the admin's snippets" do
      own_snippet(login_admin, title: "孔乙己")

      get(snippets_path)

      expect(rendered).to have_css("td", text: "孔乙己")
    end

    it "shows each snippet's state" do
      own_snippet(login_admin)

      get(snippets_path)

      expect(rendered).to have_css("td", text: "New")
    end

    it "leaves out another user's snippets" do
      create(:snippet, title: "孔乙己")
      login_admin

      get(snippets_path)

      expect(rendered).to have_text("No snippets yet")
    end
  end

  describe "#new" do
    it "is not found for a user who is not an admin" do
      login_as(default_user)

      get(new_snippet_path)

      expect(response).to have_http_status(:not_found)
    end

    it "offers the admin's word_lists by name" do
      create(:word_list, user: login_admin, name: "Lu Xun")

      get(new_snippet_path)

      expect(rendered).to have_css("datalist option[value='Lu Xun']")
    end
  end

  describe "#create" do
    it "is not found for a user who is not an admin" do
      login_as(default_user)

      post(snippets_path, params: snippet_params)

      expect(response).to have_http_status(:not_found)
    end

    it "creates the snippet" do
      login_admin

      expect { post(snippets_path, params: snippet_params) }
        .to change(Snippet, :count).by(1)
    end

    it "redirects to the snippets" do
      login_admin

      post(snippets_path, params: snippet_params)

      expect(response).to redirect_to(snippets_path)
    end

    it "renders the form again with the errors" do
      login_admin

      post(snippets_path, params: snippet_params(title: ""))

      expect(rendered).to have_text("Title can't be blank")
    end

    it "keeps what was typed" do
      login_admin

      post(snippets_path, params: snippet_params(title: ""))

      expect(rendered).to have_field("Word List", with: "Lu Xun")
    end

    it "renders the form again when a field is left out" do
      login_admin

      post(snippets_path, params: { snippet: { title: "孔乙己" } })

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
