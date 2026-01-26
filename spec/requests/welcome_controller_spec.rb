# frozen_string_literal: true

RSpec.describe WelcomeController do
  describe "#index" do
    it "renders the welcome index view" do
      get(root_path)

      expect(response.body).to include("Memorize Anything")
    end

    it "redirects logged-in users to decks page" do
      login_as(default_user)

      get(root_path)

      expect(response).to redirect_to(decks_path)
    end
  end
end
