require 'rails_helper'

RSpec.describe Todo, type: :model do
  let(:user) { create(:user) }
  let(:todo) { build(:todo, user: user) }

  describe "associations" do
    it "belongs to a user" do
      expect(todo.user).to be_present
      expect(todo.user).to be_a(User)
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(todo).to be_valid
    end

    it "requires a title" do
      todo.title = nil
      expect(todo).not_to be_valid
      expect(todo.errors[:title]).to include("can't be blank")
    end

    it "requires title to be at least 1 character" do
      todo.title = ""
      expect(todo).not_to be_valid
      expect(todo.errors[:title]).to include("is too short (minimum is 1 character)")
    end

    it "requires title to be at most 255 characters" do
      todo.title = "a" * 256
      expect(todo).not_to be_valid
      expect(todo.errors[:title]).to include("is too long (maximum is 255 characters)")
    end

    it "allows priority to be nil" do
      todo.priority = nil
      expect(todo).to be_valid
    end

    it "validates priority is between 1 and 5 when present" do
      todo.priority = 0
      expect(todo).not_to be_valid
      expect(todo.errors[:priority]).to include("is not included in the list")

      todo.priority = 6
      expect(todo).not_to be_valid
      expect(todo.errors[:priority]).to include("is not included in the list")

      todo.priority = 3
      expect(todo).to be_valid
    end

    it "allows description to be nil" do
      todo.description = nil
      expect(todo).to be_valid
    end

    it "allows due_date to be nil" do
      todo.due_date = nil
      expect(todo).to be_valid
    end
  end

  describe "defaults" do
    it "sets completed to false by default" do
      todo = Todo.new
      expect(todo.completed).to be false
    end

    it "sets priority to 1 by default" do
      todo = Todo.new
      expect(todo.priority).to eq(1)
    end
  end

  describe "scopes" do
    let!(:completed_todo) { create(:todo, user: user, completed: true) }
    let!(:pending_todo) { create(:todo, user: user, completed: false) }
    let!(:overdue_todo) { create(:todo, user: user, due_date: 2.days.ago, completed: false) }
    let!(:due_today_todo) { create(:todo, user: user, due_date: Time.current, completed: false) }

    describe ".completed" do
      it "returns only completed todos" do
        expect(Todo.completed).to include(completed_todo)
        expect(Todo.completed).not_to include(pending_todo)
      end
    end

    describe ".pending" do
      it "returns only pending todos" do
        expect(Todo.pending).to include(pending_todo)
        expect(Todo.pending).not_to include(completed_todo)
      end
    end

    describe ".overdue" do
      it "returns only overdue and uncompleted todos" do
        expect(Todo.overdue).to include(overdue_todo)
        expect(Todo.overdue).not_to include(completed_todo)
        expect(Todo.overdue).not_to include(due_today_todo)
        expect(Todo.overdue).not_to include(pending_todo)
      end
    end

    describe ".due_today" do
      it "returns only todos due today" do
        expect(Todo.due_today).to include(due_today_todo)
        expect(Todo.due_today).not_to include(overdue_todo)
        expect(Todo.due_today).not_to include(completed_todo)
      end
    end
  end

  describe "instance methods" do
    describe "#overdue?" do
      context "when todo has no due date" do
        it "returns false" do
          todo.due_date = nil
          expect(todo.overdue?).to be false
        end
      end

      context "when todo is completed" do
        it "returns false even if overdue" do
          todo.due_date = 1.day.ago
          todo.completed = true
          expect(todo.overdue?).to be false
        end
      end

      context "when todo is overdue and not completed" do
        it "returns true" do
          todo.due_date = 1.day.ago
          todo.completed = false
          expect(todo.overdue?).to be true
        end
      end

      context "when todo is not overdue" do
        it "returns false" do
          todo.due_date = 1.day.from_now
          todo.completed = false
          expect(todo.overdue?).to be false
        end
      end
    end

    describe "#due_soon?" do
      context "when todo has no due date" do
        it "returns false" do
          todo.due_date = nil
          expect(todo.due_soon?).to be false
        end
      end

      context "when todo is completed" do
        it "returns false even if due soon" do
          todo.due_date = 12.hours.from_now
          todo.completed = true
          expect(todo.due_soon?).to be false
        end
      end

      context "when todo is due within 24 hours and not completed" do
        it "returns true" do
          todo.due_date = 12.hours.from_now
          todo.completed = false
          expect(todo.due_soon?).to be true
        end
      end

      context "when todo is not due soon" do
        it "returns false" do
          todo.due_date = 2.days.from_now
          todo.completed = false
          expect(todo.due_soon?).to be false
        end
      end
    end
  end

  describe "factory" do
    it "has a valid factory" do
      expect(todo).to be_valid
    end

    it "creates a todo with default attributes" do
      todo = create(:todo, user: user)
      expect(todo.title).to be_present
      expect(todo.completed).to be false
      expect(todo.priority).to eq(1)
      expect(todo.user).to eq(user)
    end
  end
end
