# Twitter-like Rails App Development Plan

## Phase 1: Project Setup & Foundation

### Step 1: Create New Rails Application
```bash
rails new twitter_clone --css=tailwind
cd twitter_clone
```

**Concepts to Learn:**
- Rails application structure
- PostgreSQL vs SQLite
- Tailwind CSS integration
- Rails generators and conventions

### Step 2: Setup Database & Basic Configuration
```bash
rails db:create
rails db:migrate
```

**Concepts to Learn:**
- Database configuration in Rails
- Migration system
- Environment-specific configs

## Phase 2: User Authentication & Authorization

### Step 3: Install and Configure Devise
```bash
bundle add devise
rails generate devise:install
rails generate devise User
rails db:migrate
```

**Concepts to Learn:**
- Devise gem for authentication
- User model and authentication flows
- Rails routes and REST conventions
- Model validations

### Step 4: Customize User Model
```bash
rails generate migration AddFieldsToUsers username:string bio:text
rails db:migrate
```

**Concepts to Learn:**
- Database migrations
- Model associations
- Active Record validations
- Custom user attributes

## Phase 3: Core Models & Relationships

### Step 5: Create Tweet Model
```bash
# This command uses Rails' generator to create a new model called "Tweet" with two fields:
# - content:text   (a text column for the tweet's content)
# - user:references (a reference to the user who created the tweet, setting up a foreign key)
rails generate model Tweet content:text user:references
rails db:migrate
```

**Concepts to Learn:**
- Model associations (belongs_to, has_many)
- Database relationships
- Foreign keys and references
- Model validations

### Step 6: Create Like Model
```bash
rails generate model Like user:references tweet:references
rails generate migration CreateLikes user:references tweet:references
rails db:migrate
```

**Concepts to Learn:**
- Many-to-many relationships
- Join tables
- Polymorphic associations (optional)

### Step 7: Create Follow Model
```bash
# The Follow model represents the "following" relationship between users.
# Both follower and followed are references to the User model, enabling a self-referential association.
# To create a polymorphic association, you use `:references` with the `polymorphic: true` option.
# For a self-referential follow model (where both follower and followed are users), you usually do NOT need polymorphic.
# Instead, you can generate the model like this:
rails generate model Follow follower:references followed:references

# Then, in the migration file, you can specify the foreign keys to the users table:
# t.references :follower, foreign_key: { to_table: :users }
# t.references :followed, foreign_key: { to_table: :users }
# This sets up the self-referential association correctly.

rails db:migrate
```

**Concepts to Learn:**
- Self-referential associations
- Following/follower relationships
- Complex SQL queries

## Phase 4: Controllers & Routes

### Step 8: Generate Controllers
```bash
rails generate controller Tweets index show new create edit update destroy
rails generate controller Home index
rails generate controller Profiles show
```

**Concepts to Learn:**
- RESTful routing
- Controller actions and conventions
- Strong parameters
- Before_action filters

### Step 9: Setup Routes
```bash
# Add to config/routes.rb manually
```

**Concepts to Learn:**
- Rails routing system
- Nested routes
- Resource routing
- Custom routes

## Phase 5: Views & Frontend

### Step 10: Create Basic Views
```bash
# Create ERB templates manually
```

**Concepts to Learn:**
- ERB templating
- Rails view helpers
- Layouts and partials
- Asset pipeline

### Step 11: Style with Tailwind
```bash
# Configure Tailwind CSS
```

**Concepts to Learn:**
- CSS frameworks
- Responsive design
- Component-based styling

## Phase 6: Advanced Features

### Step 12: Add Real-time Features
```bash
bundle add turbo-rails
bundle add stimulus-rails
```

**Concepts to Learn:**
- Hotwire/Turbo
- Stimulus JavaScript
- Real-time updates
- WebSocket concepts

### Step 13: Add Search Functionality
```bash
bundle add pg_search
```

**Concepts to Learn:**
- Full-text search
- Database indexing
- Search algorithms

### Step 14: Add Image Upload
```bash
bundle add image_processing
bundle add active_storage
rails active_storage:install
rails db:migrate
```

**Concepts to Learn:**
- File uploads
- Active Storage
- Image processing
- Cloud storage (optional)

## Phase 7: Testing & Deployment

### Step 15: Setup Testing
```bash
bundle add rspec-rails
bundle add factory_bot_rails
rails generate rspec:install
```

**Concepts to Learn:**
- RSpec testing framework
- Test-driven development
- Factory patterns
- Test coverage

### Step 16: Prepare for Deployment
```bash
bundle add puma
bundle add pg
```

**Concepts to Learn:**
- Production deployment
- Environment variables
- Database optimization
- Performance monitoring

## Phase 8: Polish & Enhancement

### Step 17: Add Notifications
```bash
rails generate model Notification user:references notifiable:references{polymorphic} read:boolean
rails db:migrate
```

**Concepts to Learn:**
- Polymorphic associations
- Background jobs
- Notification systems

### Step 18: Add API Endpoints
```bash
rails generate controller Api::V1::Tweets index show create
```

**Concepts to Learn:**
- API design
- JSON serialization
- API authentication
- Versioning strategies

## Key Learning Concepts Throughout:

### Rails Fundamentals
- MVC architecture
- Convention over configuration
- Active Record ORM
- Action Controller
- Action View

### Database Design
- Database normalization
- Indexing strategies
- Query optimization
- Database relationships

### Security
- Authentication vs authorization
- CSRF protection
- SQL injection prevention
- XSS protection

### Performance
- N+1 query problem
- Database indexing
- Caching strategies
- Background job processing

### Modern Rails
- Hotwire/Turbo
- Stimulus
- Import maps
- CSS bundling

## Recommended Learning Order:
1. Start with basic Rails concepts (MVC, routing, models)
2. Learn authentication with Devise
3. Understand database relationships and Active Record
4. Master view templating and helpers
5. Learn JavaScript integration with Stimulus
6. Explore real-time features with Turbo
7. Understand testing and deployment
8. Advanced topics (polymorphic associations, background jobs)

This plan will take you from a Rails beginner to building a production-ready social media application. Each step builds upon the previous ones, so take your time to understand the concepts before moving forward.
