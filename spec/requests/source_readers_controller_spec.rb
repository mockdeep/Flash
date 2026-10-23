# frozen_string_literal: true

require "rails_helper"

RSpec.describe SourceReadersController do
  # An admin's source, with a finished section to start a deck at.
  def admin_source
    admin = create(:user, :admin)
    login_as(admin)
    source = create(:source, word_list: create(:word_list, user: admin))
    create(:snippet, :finished, source:)
    source
  end

  def grant(source, username)
    post(source_readers_path(source), params: { reader: { username: } })
  end

  describe "#index" do
    it "is not found for a user who is not an admin" do
      login_as(default_user)

      get(source_readers_path(create(:source)))

      expect(response).to have_http_status(:not_found)
    end

    it "is not found for another user's source" do
      admin_source

      get(source_readers_path(create(:source)))

      expect(response).to have_http_status(:not_found)
    end

    it "lists the source's readers" do
      source = admin_source
      create(:source_reader, source:, user: create(:user, username: "ann"))

      get(source_readers_path(source))

      expect(rendered).to have_css("td", text: "ann")
    end

    it "says when the source has no readers" do
      get(source_readers_path(admin_source))

      expect(rendered).to have_text("No readers yet")
    end
  end

  describe "#create" do
    it "is not found for a user who is not an admin" do
      login_as(default_user)

      grant(create(:source), default_user.username)

      expect(response).to have_http_status(:not_found)
    end

    it "lets the user read the source" do
      source = admin_source
      user = create(:user, username: "ann")

      grant(source, "ann")

      expect(source.readable_by?(user)).to be(true)
    end

    it "redirects to the source's readers" do
      source = admin_source
      create(:user, username: "ann")

      grant(source, "ann")

      expect(response).to redirect_to(source_readers_path(source))
    end

    it "renders the page again with the error" do
      grant(admin_source, "nobody")

      expect(rendered).to have_text("No user named nobody")
    end

    it "responds unprocessable for an unknown username" do
      grant(admin_source, "nobody")

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "#destroy" do
    it "is not found for a user who is not an admin" do
      login_as(default_user)
      reader = create(:source_reader)

      delete(source_reader_path(reader.source, reader))

      expect(response).to have_http_status(:not_found)
    end

    it "takes the reader's access away" do
      reader = create(:source_reader, source: admin_source)

      expect { delete(source_reader_path(reader.source, reader)) }
        .to delete_record(reader)
    end

    it "keeps the reader's deck" do
      reader = create(:source_reader, source: admin_source)
      deck = reader.user.deck_starting(reader.source)

      delete(source_reader_path(reader.source, reader))

      expect(Deck.exists?(deck.id)).to be(true)
    end

    it "redirects to the source's readers" do
      reader = create(:source_reader, source: admin_source)

      delete(source_reader_path(reader.source, reader))

      expect(response).to redirect_to(source_readers_path(reader.source))
    end
  end
end
