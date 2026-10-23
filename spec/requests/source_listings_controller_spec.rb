# frozen_string_literal: true

RSpec.describe SourceListingsController do
  def admin_source
    admin = create(:user, :admin)
    login_as(admin)
    create(:source, word_list: create(:word_list, user: admin))
  end

  describe "#create" do
    it "lists the source in the catalog" do
      source = admin_source

      expect { post(source_listing_path(source)) }
        .to change { source.reload.listed? }.to(true)
    end

    it "leaves a listed source listed" do
      source = admin_source
      post(source_listing_path(source))

      expect { post(source_listing_path(source)) }
        .not_to change(SourceListing, :count)
    end

    it "goes back to the source" do
      source = admin_source

      post(source_listing_path(source))

      expect(response).to redirect_to(source_path(source))
    end

    it "is not found for a user who is not an admin" do
      login_as(default_user)

      post(source_listing_path(create(:source)))

      expect(response).to have_http_status(:not_found)
    end

    it "is not found for another user's source" do
      admin_source

      post(source_listing_path(create(:source)))

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "#destroy" do
    it "takes the source out of the catalog" do
      source = admin_source
      create(:source_listing, source:)

      expect { delete(source_listing_path(source)) }
        .to change { source.reload.listed? }.to(false)
    end

    it "goes back to an unlisted source" do
      source = admin_source

      delete(source_listing_path(source))

      expect(response).to redirect_to(source_path(source))
    end
  end
end
