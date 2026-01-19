# frozen_string_literal: true

RSpec.describe AccountsController do
  def valid_create_params
    {
      user: {
        email: "demo@exampoo.com",
        password: "super-secure",
        password_confirmation: "super-secure",
      },
    }
  end

  def invalid_create_params
    {
      user: {
        email: "demo#exampoo.com",
        password: "super-secure",
        password_confirmation: "not-super-insecure",
      },
    }
  end

  describe "#new" do
    it "renders a new form" do
      get(new_account_path)

      expect(response.body).to include("New Account")
    end
  end

  describe "#create" do
    context "when the user successfully saves" do
      it "flashes a success message" do
        post(account_path, params: valid_create_params)

        expect(flash[:success]).to include("Account created")
      end

      it "sets the user_id in the session" do
        post(account_path, params: valid_create_params)

        expect(session[:user_id]).to eq(User.last.id)
      end

      it "redirects to the root path" do
        post(account_path, params: valid_create_params)

        expect(response).to redirect_to(root_path)
      end
    end

    context "when the user does not successfully save" do
      it "flashes an error message" do
        post(account_path, params: invalid_create_params)

        expect(response.body).to include("There was a problem")
      end

      it "renders the new page" do
        post(account_path, params: invalid_create_params)

        expect(response.body).to include("New Account")
      end
    end
  end

  describe "#show" do
    it "redirects to log in page when user is not logged in" do
      get(account_path)

      expect(response).to redirect_to(new_session_path)
    end

    it "renders the user account page" do
      login_as(default_user)

      get(account_path)

      expect(response.body).to include("My Account")
    end
  end

  describe "#update" do
    def valid_update_params = { user: { email: "new@email.com" } }
    def invalid_update_params = { user: { email: "new#email.com" } }

    context "when the user is not logged in" do
      it "redirects to log in page" do
        put(account_path, params: valid_update_params)

        expect(response).to redirect_to(new_session_path)
      end

      it "does not update the user" do
        user = User.create!(valid_create_params[:user])

        expect { put(account_path, params: valid_update_params) }
          .to not_change_record(user, :email).from("demo@exampoo.com")
      end
    end

    context "when the user successfully updates" do
      it "updates the user" do
        login_as(default_user)

        expect { put(account_path, params: valid_update_params) }
          .to change_record(default_user, :email)
          .to("new@email.com")
      end

      it "flashes a success message" do
        login_as(default_user)

        put(account_path, params: valid_update_params)

        expect(flash[:success]).to include("updated successfully")
      end

      it "redirects to the root path" do
        login_as(default_user)

        put(account_path, params: valid_update_params)

        expect(response).to redirect_to(root_path)
      end
    end

    context "when the user does not successfully update" do
      it "does not update the user" do
        login_as(default_user)

        expect { put(account_path, params: invalid_update_params) }
          .not_to change_record(default_user, :email)
      end

      it "flashes an error message" do
        login_as(default_user)

        put(account_path, params: invalid_update_params)

        expect(flash.now[:error]).to include("problem updating your account")
      end

      it "renders the show template" do
        login_as(default_user)

        put(account_path, params: invalid_update_params)

        expect(response.body).to include("My Account")
      end
    end
  end

  describe "#destroy" do
    context "when user is not logged in" do
      it "redirects to log in page" do
        delete(account_path)

        expect(response).to redirect_to(new_session_path)
      end

      it "does not destroy the user" do
        user = User.create!(valid_create_params[:user])

        expect { delete(account_path) }.to not_delete_record(user)
      end
    end

    context "when the user is successfully destroyed" do
      it "clears the session" do
        login_as(default_user)

        delete(account_path)

        expect(session[:user_id]).to be_nil
      end

      it "flashes a success message" do
        login_as(default_user)

        delete(account_path)

        expect(flash[:success]).to include("Account permanently deleted")
      end

      it "redirects to the root path" do
        login_as(default_user)

        delete(account_path)

        expect(response).to redirect_to(root_path)
      end
    end
  end
end
