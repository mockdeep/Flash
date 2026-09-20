# frozen_string_literal: true

RSpec.describe "Jobs dashboard" do
  it "is not found for anonymous visitors" do
    get("/jobs")

    expect(response).to have_http_status(:not_found)
  end

  it "is not found for signed-in non-admins" do
    login_as(create(:user))

    get("/jobs")

    expect(response).to have_http_status(:not_found)
  end

  it "renders for admins" do
    login_as(create(:user, :admin))

    get("/jobs")

    expect(response).to have_http_status(:ok)
  end
end
