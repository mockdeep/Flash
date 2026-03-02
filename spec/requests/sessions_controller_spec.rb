# frozen_string_literal: true

RSpec.describe SessionsController do
  let(:password) { "super-secure" }
  let(:user) do
    create(
      :user,
      email: "demo@exampoo.com",
      password:,
      password_confirmation: password,
    )
  end

  def valid_create_params = { session: { email: user.email, password: } }

  def invalid_create_params
    {
      session: {
        email: "wrong@email",
        password: "wrong password",
      },
    }
  end

  describe "#new" do
    it "renders a new form" do
      get(new_session_path)

      expect(response.body).to include("Log in to")
    end
  end

  describe "#create" do
    context "when user authenticates" do
      it "sets the user id in the session" do
        post(session_path, params: valid_create_params)

        expect(session[:user_id]).to eq(user.id)
      end

      it "redirects to the home page" do
        user
        post(session_path, params: valid_create_params)

        expect(response).to redirect_to(root_path)
      end
    end

    context "when user does not authenticate" do
      it "flashes an error" do
        user
        post(session_path, params: invalid_create_params)

        expect(response.body).to include("Invalid email or password")
      end

      it "renders the new template" do
        user
        post(session_path, params: invalid_create_params)

        expect(response.body).to include("Log in to")
      end
    end
  end

  describe "#destroy" do
    it "redirects to log in page when user is not logged in" do
      delete(session_path)

      expect(response).to redirect_to(new_session_path)
    end

    it "clears the session" do
      login_as(default_user)

      delete(session_path)

      expect(session).to be_empty
    end

    it "redirects to the home page" do
      login_as(default_user)

      delete(session_path)

      expect(response).to redirect_to(root_path)
    end
  end
end
