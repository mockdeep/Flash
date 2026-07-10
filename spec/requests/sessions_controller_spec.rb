# frozen_string_literal: true

RSpec.describe SessionsController do
  def create_user
    create(
      :user,
      email: "demo@exampoo.com",
      password: "super-secure",
      password_confirmation: "super-secure",
    )
  end

  def valid_create_params(user)
    { session: { email: user.email, password: "super-secure" } }
  end

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
        user = create_user
        post(session_path, params: valid_create_params(user))

        expect(session[:user_id]).to eq(user.id)
      end

      it "redirects to the home page" do
        user = create_user
        post(session_path, params: valid_create_params(user))

        expect(response).to redirect_to(root_path)
      end
    end

    context "when user does not authenticate" do
      it "flashes an error" do
        create_user
        post(session_path, params: invalid_create_params)

        expect(response.body).to include("Invalid email or password")
      end

      it "renders the new template" do
        create_user
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
