# README

# Getting started

This will create a new resource called `blog.`

```sh
# Step 1: Create a new Rails application called "blog"
rails new blog

# Step 2: Generate a scaffold for the "post" resource, which will create all the necessary files for a Post model
# with a "title" (string) and "body" (text) field, as well as controllers, views, routes, and tests.
rails generate scaffold post title:string body:text

# Step 3: Run the database migrations to create the "posts" table and any other required tables in your database.
rails db:migrate
```

# Console

```sh
rails console
>> Post.first.update! title: "Changed from CLI"
```

# Create a comments resource

This will generate a new resource for `comments`.

Note that this is less verbose than `scaffold`, there are less files that this will generate:

```sh
# This command generates a new Rails resource called "comment" with a reference to the "post" model (creating a post_id foreign key)
# and a "content" field of type text. The second command runs the database migration to create the corresponding table and columns.
rails g resource comment post:references content:text
rails db:migrate
```
