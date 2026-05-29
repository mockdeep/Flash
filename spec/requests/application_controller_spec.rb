# frozen_string_literal: true

RSpec.describe ApplicationController, type: :controller do
  controller do
    skip_before_action(:authenticate_user)

    def index
      render(plain: Time.zone.name)
    end
  end

  it "runs the request in the current user's time zone" do
    user = create(:user, time_zone: "America/New_York")
    session[:user_id] = user.id

    get(:index)

    expect(response.body).to eq("America/New_York")
  end

  it "falls back to UTC when no user is logged in" do
    get(:index)

    expect(response.body).to eq("UTC")
  end
end
