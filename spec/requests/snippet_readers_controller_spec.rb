# frozen_string_literal: true

require "rails_helper"

RSpec.describe SnippetReadersController do
  def admin_snippet
    admin = create(:user, :admin)
    login_as(admin)
    create(:snippet, word_list: create(:word_list, user: admin))
  end

  def grant(snippet, username)
    post(snippet_readers_path(snippet), params: { reader: { username: } })
  end

  describe "#index" do
    it "is not found for a user who is not an admin" do
      login_as(default_user)

      get(snippet_readers_path(create(:snippet)))

      expect(response).to have_http_status(:not_found)
    end

    it "is not found for another user's snippet" do
      admin_snippet

      get(snippet_readers_path(create(:snippet)))

      expect(response).to have_http_status(:not_found)
    end

    it "lists the snippet's readers" do
      snippet = admin_snippet
      create(:snippet_reader, snippet:, user: create(:user, username: "ann"))

      get(snippet_readers_path(snippet))

      expect(rendered).to have_css("td", text: "ann")
    end

    it "says when the snippet has no readers" do
      get(snippet_readers_path(admin_snippet))

      expect(rendered).to have_text("No readers yet")
    end
  end

  describe "#create" do
    it "is not found for a user who is not an admin" do
      login_as(default_user)

      grant(create(:snippet), default_user.username)

      expect(response).to have_http_status(:not_found)
    end

    it "lets the user read the snippet" do
      snippet = admin_snippet
      user = create(:user, username: "ann")

      grant(snippet, "ann")

      expect(snippet.readable_by?(user)).to be(true)
    end

    it "redirects to the snippet's readers" do
      snippet = admin_snippet
      create(:user, username: "ann")

      grant(snippet, "ann")

      expect(response).to redirect_to(snippet_readers_path(snippet))
    end

    it "renders the page again with the error" do
      grant(admin_snippet, "nobody")

      expect(rendered).to have_text("No user named nobody")
    end

    it "responds unprocessable for an unknown username" do
      grant(admin_snippet, "nobody")

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "#destroy" do
    it "is not found for a user who is not an admin" do
      login_as(default_user)
      reader = create(:snippet_reader)

      delete(snippet_reader_path(reader.snippet, reader))

      expect(response).to have_http_status(:not_found)
    end

    it "takes the reader's access away" do
      reader = create(:snippet_reader, snippet: admin_snippet)

      expect { delete(snippet_reader_path(reader.snippet, reader)) }
        .to delete_record(reader)
    end

    it "keeps the reader's deck" do
      reader = create(:snippet_reader, snippet: admin_snippet)
      deck = reader.user.reading_deck_over(reader.snippet.word_list)

      delete(snippet_reader_path(reader.snippet, reader))

      expect(Deck.exists?(deck.id)).to be(true)
    end

    it "redirects to the snippet's readers" do
      reader = create(:snippet_reader, snippet: admin_snippet)

      delete(snippet_reader_path(reader.snippet, reader))

      expect(response).to redirect_to(snippet_readers_path(reader.snippet))
    end
  end
end
