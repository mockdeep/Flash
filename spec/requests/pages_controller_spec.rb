# frozen_string_literal: true

require "rails_helper"

RSpec.describe PagesController do
  describe "#pricing" do
    it "renders the pricing page" do
      get(pricing_path)

      expect(rendered).to have_content("Pricing")
    end

    it "shows 'Current Plan' link for logged-in users" do
      login_as(default_user)

      get(pricing_path)

      expect(rendered).to have_content("Current Plan")
    end

    it "shows 'Subscribe' link for logged-in users" do
      login_as(default_user)

      get(pricing_path)

      expect(rendered).to have_content("Subscribe")
    end
  end

  describe "#privacy" do
    it "renders the privacy page" do
      get(privacy_path)

      expect(rendered).to have_content("Privacy Policy")
    end
  end

  describe "#terms" do
    it "renders the terms page" do
      get(terms_path)

      expect(rendered).to have_content("Terms of Service")
    end
  end
end
