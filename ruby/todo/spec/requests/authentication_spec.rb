require 'rails_helper'

RSpec.describe "Authentication", type: :request do
  describe "User Registration" do
    context "GET /users/sign_up" do
      it "returns http success" do
        get new_user_registration_path
        expect(response).to have_http_status(:success)
      end

      it "displays the registration form" do
        get new_user_registration_path
        expect(response.body).to include("Create your account")
        expect(response.body).to include("Email address")
        expect(response.body).to include("Password")
        expect(response.body).to include("Confirm password")
      end
    end

    context "POST /users" do
      let(:valid_params) do
        {
          user: {
            email: "test@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end

      it "creates a new user with valid params" do
        expect {
          post user_registration_path, params: valid_params
        }.to change(User, :count).by(1)
      end

      it "redirects to todos after successful registration" do
        post user_registration_path, params: valid_params
        expect(response).to redirect_to(todos_path)
      end

      it "sets a success notice" do
        post user_registration_path, params: valid_params
        expect(flash[:notice]).to eq("Welcome! You have signed up successfully.")
      end

      context "with invalid params" do
        let(:invalid_params) do
          {
            user: {
              email: "invalid-email",
              password: "short",
              password_confirmation: "different"
            }
          }
        end

        it "does not create a user" do
          expect {
            post user_registration_path, params: invalid_params
          }.not_to change(User, :count)
        end

        it "renders the registration form again" do
          post user_registration_path, params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "displays error messages" do
          post user_registration_path, params: invalid_params
          expect(response.body).to include("error")
        end
      end
    end
  end

  describe "User Sign In" do
    let(:user) { create(:user, email: "user@example.com", password: "password123") }

    context "GET /users/sign_in" do
      it "returns http success" do
        get new_user_session_path
        expect(response).to have_http_status(:success)
      end

      it "displays the sign in form" do
        get new_user_session_path
        expect(response.body).to include("Sign in to your account")
        expect(response.body).to include("Email address")
        expect(response.body).to include("Password")
      end
    end

    context "POST /users/sign_in" do
      it "signs in user with valid credentials" do
        post user_session_path, params: {
          user: { email: user.email, password: "password123" }
        }
        expect(response).to redirect_to(todos_path)
      end

      it "sets a success notice" do
        post user_session_path, params: {
          user: { email: user.email, password: "password123" }
        }
        expect(flash[:notice]).to eq("Signed in successfully.")
      end

      context "with invalid credentials" do
        it "does not sign in user with wrong password" do
          post user_session_path, params: {
            user: { email: user.email, password: "wrongpassword" }
          }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "does not sign in user with non-existent email" do
          post user_session_path, params: {
            user: { email: "nonexistent@example.com", password: "password123" }
          }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe "User Sign Out" do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    it "signs out the user" do
      delete destroy_user_session_path
      expect(response).to redirect_to(root_path)
    end

    it "sets a success notice" do
      delete destroy_user_session_path
      expect(flash[:notice]).to eq("Signed out successfully.")
    end
  end

  describe "Password Reset" do
    context "GET /users/password/new" do
      it "returns http success" do
        get new_user_password_path
        expect(response).to have_http_status(:success)
      end

      it "displays the password reset form" do
        get new_user_password_path
        expect(response.body).to include("Reset your password")
        expect(response.body).to include("Email address")
      end
    end

    context "POST /users/password" do
      let(:user) { create(:user) }

      it "sends reset instructions for existing user" do
        expect {
          post user_password_path, params: { user: { email: user.email } }
        }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it "redirects to sign in page" do
        post user_password_path, params: { user: { email: user.email } }
        expect(response).to redirect_to(new_user_session_path)
      end

      it "sets a success notice" do
        post user_password_path, params: { user: { email: user.email } }
        expect(flash[:notice]).to eq("You will receive an email with instructions on how to reset your password in a few minutes.")
      end
    end
  end

  describe "Protected Routes" do
    context "when user is not signed in" do
      it "redirects todos index to sign in" do
        get todos_path
        expect(response).to redirect_to(new_user_session_path)
      end

      it "redirects new todo to sign in" do
        get new_todo_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is signed in" do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it "allows access to todos index" do
        get todos_path
        expect(response).to have_http_status(:success)
      end

      it "allows access to new todo form" do
        get new_todo_path
        expect(response).to have_http_status(:success)
      end
    end
  end
end
