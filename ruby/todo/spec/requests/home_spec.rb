require 'rails_helper'

RSpec.describe "Home", type: :request do
  describe "GET /" do
    it "returns http success" do
      get root_path
      expect(response).to have_http_status(:success)
    end

    it "displays the welcome page" do
      get root_path
      expect(response.body).to include("Welcome to")
      expect(response.body).to include("Todo")
      expect(response.body).to include("Get Started")
      expect(response.body).to include("Sign In")
    end

    context "when user is not signed in" do
      it "shows sign up and sign in links" do
        get root_path
        expect(response.body).to include("/users/sign_up")
        expect(response.body).to include("/users/sign_in")
      end
    end

    context "when user is signed in" do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it "shows link to todos" do
        get root_path
        expect(response.body).to include("Go to My Todos")
        expect(response.body).to include(todos_path)
      end
    end
  end
end
