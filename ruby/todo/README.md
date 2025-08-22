# Todo App

This is a simple Todo application built with Ruby on Rails. The app allows users to create, view, update, and delete their todo items.

## Features

- Add new todo items
- Mark todos as complete or incomplete
- Edit existing todos
- Delete todos
- View a list of all your todos

## Getting Started

Follow these steps to set up and run the Todo app on your local machine.

### Prerequisites

- Ruby (version 3.0 or higher recommended)
- Rails (version 6 or higher)
- SQLite3 (for development)

### Setup

1. **Clone the repository**

   ```sh
   git clone <repository-url>
   cd todo
   ```

2. **Install dependencies**

   ```sh
   bundle install
   ```

3. **Set up the database**

   ```sh
   rails db:create
   rails db:migrate
   ```

4. **Start the Rails server**

   ```sh
   rails server
   ```

5. **Open the app in your browser**

   Visit [http://localhost:3000](http://localhost:3000) to use the Todo app.

## Usage

- Click "New Todo" to add a new task.
- Use the edit and delete buttons to manage your todos.
- Mark tasks as complete or incomplete as you work through your list.
