# frozen_string_literal: true

require "rails_helper"

RSpec.describe SnippetsController do
  def admin_source
    admin = create(:user, :admin)
    login_as(admin)
    create(:source, word_list: create(:word_list, user: admin), title: "春节")
  end

  def snippet_params(body: "我爱你。")
    { snippet: { heading: "习俗", body: } }
  end

  describe "#new" do
    it "is not found for a user who is not an admin" do
      login_as(default_user)

      get(new_source_snippet_path(create(:source)))

      expect(response).to have_http_status(:not_found)
    end

    it "is not found for another user's source" do
      admin_source

      get(new_source_snippet_path(create(:source)))

      expect(response).to have_http_status(:not_found)
    end

    it "names the source the snippet joins" do
      get(new_source_snippet_path(admin_source))

      expect(rendered).to have_link("← Back to 春节")
    end
  end

  describe "#create" do
    it "is not found for a user who is not an admin" do
      login_as(default_user)

      post(source_snippets_path(create(:source)), params: snippet_params)

      expect(response).to have_http_status(:not_found)
    end

    it "adds the snippet to the source" do
      source = admin_source

      post(source_snippets_path(source), params: snippet_params)

      expect(source.snippets.sole.heading).to eq("习俗")
    end

    it "redirects to the source" do
      source = admin_source

      post(source_snippets_path(source), params: snippet_params)

      expect(response).to redirect_to(source_path(source))
    end

    it "renders the form again with the errors" do
      source = admin_source

      post(source_snippets_path(source), params: snippet_params(body: ""))

      expect(rendered).to have_text("Body can't be blank")
    end

    it "keeps what was typed" do
      source = admin_source

      post(source_snippets_path(source), params: snippet_params(body: ""))

      expect(rendered).to have_field("Heading (optional)", with: "习俗")
    end
  end
end
