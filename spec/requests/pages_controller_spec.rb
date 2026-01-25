# frozen_string_literal: true

require "rails_helper"

RSpec.describe PagesController do
  describe "GET /pricing" do
    it "renders the pricing page" do
      get(pricing_path)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /privacy" do
    it "renders the privacy page" do
      get(privacy_path)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /terms" do
    it "renders the terms page" do
      get(terms_path)

      expect(response).to have_http_status(:ok)
    end
  end
end
