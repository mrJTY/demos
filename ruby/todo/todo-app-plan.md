# Todo List App - Ruby on Rails Implementation Plan

## Quick Start Commands
```bash
# Prerequisites - Make sure you have these installed:
# - Ruby 3.0+ (check with: ruby --version)
# - Rails 7.0+ (check with: rails --version)
# - SQLite3 (check with: sqlite3 --version)
# - Node.js (check with: node --version)

# Clone or create your project directory
mkdir todo && cd todo

# Follow the step-by-step commands below for each phase
```

## Project Overview
A full-featured todo list application built with Ruby on Rails, featuring user authentication, CRUD operations for todos, categories, and a modern responsive interface.

## Core Features

### 1. User Management
- User registration and authentication (using Devise gem)
- User profiles with avatar support
- Password reset functionality
- Remember me functionality

### 2. Todo Management
- Create, read, update, delete todos
- Mark todos as complete/incomplete
- Set due dates and priorities
- Add notes/descriptions to todos
- Bulk operations (mark multiple as complete, delete multiple)

### 3. Organization Features
- Categorize todos with tags/categories
- Filter todos by status, category, due date, priority
- Search functionality
- Sort todos by various criteria

### 4. Advanced Features
- Recurring todos (daily, weekly, monthly)
- Todo sharing between users
- Email notifications for due dates
- Progress tracking and statistics

## Database Design

### Users Table
```sql
users
- id (primary key)
- email (string, unique)
- encrypted_password (string)
- first_name (string)
- last_name (string)
- avatar_url (string)
- created_at (datetime)
- updated_at (datetime)
```

### Categories Table
```sql
categories
- id (primary key)
- name (string)
- color (string, hex code)
- user_id (foreign key)
- created_at (datetime)
- updated_at (datetime)
```

### Todos Table
```sql
todos
- id (primary key)
- title (string)
- description (text)
- completed (boolean, default: false)
- due_date (datetime)
- priority (integer, 1-5)
- user_id (foreign key)
- category_id (foreign key)
- recurring_pattern (string, enum)
- recurring_interval (integer)
- created_at (datetime)
- updated_at (datetime)
```

### Todo Categories (Join Table)
```sql
todo_categories
- id (primary key)
- todo_id (foreign key)
- category_id (foreign key)
- created_at (datetime)
```

## Technology Stack

### Backend
- **Ruby on Rails 7.0+** - Web framework
- **PostgreSQL** - Database
- **Devise** - Authentication
- **Pundit** - Authorization
- **RSpec** - Testing framework
- **FactoryBot** - Test data factories

### Frontend
- **Hotwire (Turbo + Stimulus)** - Modern Rails frontend
- **Tailwind CSS** - Styling
- **Alpine.js** - Lightweight JavaScript framework
- **Heroicons** - Icon set

### Development Tools
- **Docker** - Containerization
- **Git** - Version control
- **RuboCop** - Code linting
- **Brakeman** - Security scanning

## Implementation Phases

### Phase 1: Project Setup & Basic Structure (Week 1)
1. **Initialize Rails project**
   ```bash
   # Create new Rails 7 app with SQLite (default database)
   rails new todo --css=tailwind
   cd todo

   # Set up Git repository
   git init
   git add .
   git commit -m "Initial Rails app setup"

   # Install dependencies
   bundle install
   ```

2. **Basic configuration**
   ```bash
   # SQLite database is automatically configured
   # No need to set up database credentials

   # Create and migrate database
   rails db:create
   rails db:migrate

   # Add essential gems to Gemfile
   # Add these lines to your Gemfile:
   # gem 'devise'
   # gem 'pundit'
   # gem 'rspec-rails'
   # gem 'factory_bot_rails'
   # gem 'faker'

   bundle install
   ```

3. **User authentication**
   ```bash
   # Devise is a flexible authentication solution for Rails based on Warden.
   # It provides ready-to-use user authentication features such as registration, login, password recovery, and more.
   rails generate devise:install
   rails generate devise User
   rails generate devise:views

   # Run migrations
   rails db:migrate

   # Generate Devise configuration
   rails generate devise:install

   # Add Devise to application controller
   # Add 'before_action :authenticate_user!' to ApplicationController
   ```

### Phase 2: Core Models & Database (Week 2)
1. **Database design**
   ```bash
   # Generate Category model
   rails generate model Category name:string color:string user:references

   # Generate Todo model
   rails generate model Todo title:string description:text completed:boolean due_date:datetime priority:integer user:references category:references recurring_pattern:string recurring_interval:integer

   # Run migrations
   rails db:migrate

   # Add database indexes (edit migration files if needed)
   rails db:migrate:status
   ```

2. **Model development**
   ```bash
   # Set up RSpec testing environment
   rails generate rspec:install

   # Generate model specs
   rails generate rspec:model User
   rails generate rspec:model Todo
   rails generate rspec:model Category

   # Generate factories
   rails generate factory_bot:model User
   rails generate factory_bot:model Todo
   rails generate factory_bot:model Category
   ```

3. **Testing foundation**
   ```bash
   # Run tests to ensure everything is working
   bundle exec rspec

   # Check test coverage
   bundle exec rspec --format documentation
   ```

### Phase 3: Basic CRUD Operations (Week 3)
1. **Todo controller**
   ```bash
   # Generate Todos controller with all CRUD actions
   rails generate controller Todos index show new create edit update destroy

   # Generate Categories controller
   rails generate controller Categories index show new create edit update destroy

   # Check generated routes
   rails routes | grep -E "(todos|categories)"
   ```

2. **Views and forms**
   ```bash
   # Generate view templates (if not already created)
   rails generate devise:views

   # Start the Rails server to test
   rails server

   # In another terminal, test the application
   curl http://localhost:3000
   ```

3. **Basic styling**
   ```bash
   # Tailwind CSS should already be configured from Rails 7
   # Build CSS assets
   rails tailwindcss:build

   # Watch for CSS changes during development
   rails tailwindcss:watch
   ```

### Phase 4: Enhanced Features (Week 4)
1. **Categories and organization**
   ```bash
   # Add search functionality to models
   # Install pg_search gem for PostgreSQL search
   # Add to Gemfile: gem 'pg_search'
   bundle install

   # Generate search concern
   rails generate concern Searchable

   # Test category operations
   rails console
   # In console: Category.create(name: "Work", color: "#FF0000", user: User.first)
   ```

2. **Search and filtering**
   ```bash
   # Add filtering to controllers
   # Edit app/controllers/todos_controller.rb to add filtering logic

   # Test search functionality
   rails server
   # Visit http://localhost:3000/todos?search=work
   ```

3. **User experience improvements**
   ```bash
   # Turbo is already included in Rails 7
   # Test real-time updates
   # Open multiple browser tabs and create/edit todos

   # Check Turbo is working
   rails routes | grep turbo
   ```

### Phase 5: Advanced Features (Week 5)
1. **Recurring todos**
   ```bash
   # Install background job processing
   # Add to Gemfile: gem 'sidekiq'
   bundle install

   # Generate recurring todo service
   rails generate service RecurringTodoService

   # Test recurring logic
   rails console
   # In console: Todo.create(title: "Daily Standup", recurring_pattern: "daily", user: User.first)
   ```

2. **Due dates and priorities**
   ```bash
   # Add date picker JavaScript
   # Install flatpickr for date picking
   # Add to Gemfile: gem 'flatpickr-rails'
   bundle install

   # Test priority system
   rails console
   # In console: Todo.first.update(priority: 3, due_date: 1.week.from_now)
   ```

3. **Bulk operations**
   ```bash
   # Add bulk actions to todos controller
   # Edit app/controllers/todos_controller.rb to add bulk_update and bulk_delete methods

   # Test bulk operations
   rails server
   # Visit http://localhost:3000/todos and test bulk selection
   ```

### Phase 6: Polish & Testing (Week 6)
1. **Testing**
   ```bash
   # Run all tests
   bundle exec rspec

   # Run specific test files
   bundle exec rspec spec/controllers/
   bundle exec rspec spec/models/
   bundle exec rspec spec/system/

   # Generate test coverage report
   # Add to Gemfile: gem 'simplecov'
   bundle install
   bundle exec rspec
   ```

2. **Performance optimization**
   ```bash
   # Add database indexes
   rails generate migration AddIndexesToTodos
   # Edit the migration file to add indexes
   rails db:migrate

   # Install pagination
   # Add to Gemfile: gem 'kaminari'
   bundle install

   # Test performance
   rails console
   # In console: Todo.includes(:category, :user).page(1).per(25)
   ```

3. **Final touches**
   ```bash
   # Generate error pages
   rails generate controller Errors not_found internal_server_error

   # Check production build
   RAILS_ENV=production rails assets:precompile

   # Final test run
   bundle exec rspec
   rails server
   ```

## File Structure

```
app/
├── controllers/
│   ├── application_controller.rb
│   ├── todos_controller.rb
│   ├── categories_controller.rb
│   └── users_controller.rb
├── models/
│   ├── user.rb
│   ├── todo.rb
│   └── category.rb
├── views/
│   ├── layouts/
│   ├── todos/
│   ├── categories/
│   └── users/
├── helpers/
├── mailers/
└── assets/
    ├── stylesheets/
    └── javascript/
```

## Security Considerations

1. **Authentication & Authorization**
   - Use Devise for secure authentication
   - Implement Pundit policies for authorization
   - Add CSRF protection

2. **Data validation**
   - Server-side validation for all inputs
   - SQL injection prevention
   - XSS protection

3. **User privacy**
   - Ensure users can only access their own todos
   - Implement proper session management
   - Add rate limiting for API endpoints

## Testing Strategy

1. **Unit tests** - Test models, helpers, and mailers
2. **Controller tests** - Test all controller actions
3. **Integration tests** - Test user workflows
4. **System tests** - Test full user experience
5. **Security tests** - Test authorization and authentication

## Deployment Considerations

1. **Environment setup**
   - Production database configuration
   - Environment variable management
   - Asset compilation

2. **Performance**
   - Database optimization
   - CDN for static assets
   - Background job processing

3. **Monitoring**
   - Application logging
   - Error tracking (Sentry)
   - Performance monitoring

## Future Enhancements

1. **Mobile app** - React Native or Flutter companion app
2. **API development** - RESTful API for third-party integrations
3. **Collaboration features** - Shared todo lists and team management
4. **Advanced analytics** - Time tracking and productivity insights
5. **Integration** - Calendar apps, email, and productivity tools

## Success Metrics

1. **Functionality** - All core features working correctly
2. **Performance** - Page load times under 2 seconds
3. **Security** - Pass security audit and penetration testing
4. **User experience** - Intuitive interface with minimal learning curve
5. **Code quality** - High test coverage and clean, maintainable code

## Timeline Summary

- **Week 1**: Project setup and authentication
- **Week 2**: Database design and models
- **Week 3**: Basic CRUD operations
- **Week 4**: Enhanced features and organization
- **Week 5**: Advanced features and recurring todos
- **Week 6**: Testing, optimization, and deployment

Total estimated development time: **6 weeks** for a production-ready todo list application.
