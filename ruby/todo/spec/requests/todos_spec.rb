require 'rails_helper'

RSpec.describe "Todos", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user, email: "other@example.com") }

  describe "GET /todos" do
    context "when user is not signed in" do
      it "redirects to sign in page" do
        get todos_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is signed in" do
      before do
        sign_in user
      end

      it "returns http success" do
        get todos_path
        expect(response).to have_http_status(:success)
      end

      it "displays the todos page" do
        get todos_path
        expect(response.body).to include("My Todos")
        expect(response.body).to include("New Todo")
      end

      context "when user has todos" do
        let!(:todo1) { create(:todo, user: user, title: "First Todo") }
        let!(:todo2) { create(:todo, user: user, title: "Second Todo") }

        it "displays user's todos" do
          get todos_path
          expect(response.body).to include("First Todo")
          expect(response.body).to include("Second Todo")
        end

        it "does not display other users' todos" do
          create(:todo, user: other_user, title: "Other User's Todo")
          get todos_path
          expect(response.body).not_to include("Other User's Todo")
        end
      end

      context "when user has no todos" do
        it "displays empty state message" do
          get todos_path
          expect(response.body).to include("No todos yet!")
          expect(response.body).to include("Create Todo")
        end
      end
    end
  end

  describe "GET /todos/new" do
    context "when user is not signed in" do
      it "redirects to sign in page" do
        get new_todo_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is signed in" do
      before do
        sign_in user
      end

      it "returns http success" do
        get new_todo_path
        expect(response).to have_http_status(:success)
      end

      it "displays the new todo form" do
        get new_todo_path
        expect(response.body).to include("Create New Todo")
        expect(response.body).to include("What needs to be done?")
        expect(response.body).to include("Add any additional details...")
        expect(response.body).to include("Due date")
        expect(response.body).to include("Priority")
      end
    end
  end

  describe "POST /todos" do
    context "when user is not signed in" do
      it "redirects to sign in page" do
        post todos_path, params: { todo: { title: "Test Todo" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is signed in" do
      before do
        sign_in user
      end

      context "with valid params" do
        let(:valid_params) do
          {
            todo: {
              title: "Test Todo",
              description: "This is a test todo",
              due_date: 1.day.from_now,
              priority: 3
            }
          }
        end

        it "creates a new todo" do
          expect {
            post todos_path, params: valid_params
          }.to change(Todo, :count).by(1)
        end

        it "associates the todo with the current user" do
          post todos_path, params: valid_params
          expect(Todo.last.user).to eq(user)
        end

        it "redirects to todos index" do
          post todos_path, params: valid_params
          expect(response).to redirect_to(todos_path)
        end

        it "sets a success notice" do
          post todos_path, params: valid_params
          expect(flash[:notice]).to eq("Todo created successfully!")
        end

        it "sets the correct attributes" do
          post todos_path, params: valid_params
          todo = Todo.last
          expect(todo.title).to eq("Test Todo")
          expect(todo.description).to eq("This is a test todo")
          expect(todo.priority).to eq(3)
        end
      end

      context "with invalid params" do
        let(:invalid_params) do
          {
            todo: {
              title: "", # Empty title is invalid
              description: "This is a test todo"
            }
          }
        end

        it "does not create a todo" do
          expect {
            post todos_path, params: invalid_params
          }.not_to change(Todo, :count)
        end

        it "renders the new form again" do
          post todos_path, params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "displays error messages" do
          post todos_path, params: invalid_params
          expect(response.body).to include("error")
        end
      end

      context "with missing required fields" do
        let(:missing_title_params) do
          {
            todo: {
              description: "This is a test todo"
            }
          }
        end

        it "does not create a todo without title" do
          expect {
            post todos_path, params: missing_title_params
          }.not_to change(Todo, :count)
        end
      end
    end
  end

  describe "Navigation and UI" do
    before do
      sign_in user
    end

    it "shows navigation links" do
      get todos_path
      expect(response.body).to include("Home")
      expect(response.body).to include("Sign Out")
    end

    it "shows new todo button" do
      get todos_path
      expect(response.body).to include("New Todo")
    end

    it "shows create todo button in empty state" do
      get todos_path
      expect(response.body).to include("Create Todo")
    end
  end
end
