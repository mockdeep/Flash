# frozen_string_literal: true

RSpec.describe WelcomeController do
  describe "#index" do
    it "renders the welcome index view" do
      get(root_path)

      expect(response.body).to include("Welcome")
    end
  end
end
