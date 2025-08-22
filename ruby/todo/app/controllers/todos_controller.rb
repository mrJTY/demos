class TodosController < ApplicationController
  # Require authentication for all actions
  before_action :authenticate_user!
  # This controller manages actions related to the Todo model for the current user.

  def index
    # current_user is typically an instance of the User model, representing the currently signed-in user.
    @todos = current_user.todos.sort_by { |todo| -todo.created_at.to_i }
  end

  def new
    # This line initializes a new Todo object associated with the currently signed-in user.
    # It does not save the object to the database yet; it simply prepares it for use in the 'new' view form.
    @todo = current_user.todos.build
  end

  def create
    @todo = current_user.todos.build(todo_params)

    if @todo.save
      redirect_to todos_path, notice: 'Todo created successfully!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def todo_params
    params.require(:todo).permit(:title, :description, :due_date, :priority)
  end
end
