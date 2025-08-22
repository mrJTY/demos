## Plan: Background leader task increments a Counter every 10s and show it on Home

### Overview
- **Goal**: A Rails 8 app updates a `Counter` row in the DB by a random increment every 10 seconds via a background leader task, and shows the current value on the home page.
- **Stack**: Rails 8, SQLite, Solid Queue (jobs), Solid Cable (for optional live updates), Importmap.

### Data model
1) Generate model and migrate
```bash
bin/rails g model Counter value:integer
bin/rails db:migrate
```

2) Make sure an initial row exists (seed)
```ruby
# db/seeds.rb
Counter.find_or_create_by(id: 1) { |c| c.value = 0 }
```
```bash
bin/rails db:seed
```

### Background job
1) Generate job
```bash
bin/rails g job IncrementCounter
```

2) Implement atomic increment with a random step
```ruby
# app/jobs/increment_counter_job.rb
class IncrementCounterJob < ApplicationJob
  queue_as :default

  def perform
    # Ensure the singleton counter exists
    counter = Counter.find_or_create_by(id: 1) { |c| c.value = 0 }

    # Atomic increment inside a transaction with row lock
    Counter.transaction do
      counter.lock!
      counter.value += rand(1..10)
      counter.save!
    end
  end
end
```

### Do I need Sidekiq?

Short answer
Do you need Sidekiq? No. Your app already uses Solid Queue, which is enough for running background jobs and recurring leader tasks every 10 seconds.

What is Sidekiq?
* Sidekiq is a popular Ruby background job processor that uses Redis as its queue.
* It’s fast and highly concurrent, with a web UI, and rich ecosystem (e.g., scheduling via sidekiq-cron, Pro/Enterprise features).

When to use which
* Solid Queue: simplest deploy (no Redis), good for most apps, integrates tightly with Rails.
* Sidekiq: choose it if you need very high throughput/low latency, Redis-based scaling, or its advanced features.

Summary
Stick with Solid Queue for this app; it already supports the recurring leader task you need. You can switch to Sidekiq later if your scale/requirements demand it.

### Recurring schedule (leader task)
Solid Queue’s recurring scheduler reads `config/recurring.yml`. Only one leader will run each scheduled task across your processes.

Add a `development` schedule for local testing and a `production` schedule for deployment:
```yaml
# config/recurring.yml
development:
  increment_counter_every_10s:
    class: IncrementCounterJob
    queue: default
    schedule: every 10 seconds

production:
  increment_counter_every_10s:
    class: IncrementCounterJob
    queue: default
    schedule: every 10 seconds
```

Run the job runner with recurring enabled:
```bash
# Terminal 1: run job runner
bin/jobs start --recurring

# If your local Solid Queue version doesn’t need the flag, this also works:
# bin/jobs start
```

### UI: Home page showing the current value
1) Routes and controller
```bash
bin/rails g controller Home index
```
```ruby
# config/routes.rb
root "home#index"
```

2) View
```erb
<!-- app/views/home/index.html.erb -->
<h1>Counter</h1>
<p>Current value: <%= Counter.first&.value || 0 %></p>
```

### Run locally
```bash
# Prepare DB
bin/rails db:prepare
bin/rails db:seed

# Terminal 1: background jobs (recurring scheduler + workers)
bin/jobs start --recurring

# Terminal 2: web server
bin/rails server

# Open http://localhost:3000 and watch the number change every ~10s (on refresh)
```

### Optional: live updates (Turbo Streams)
If you want the number to update without refreshing:

1) Broadcast on save
```ruby
# app/models/counter.rb
class Counter < ApplicationRecord
  after_commit -> { broadcast_replace_to(:counter, target: "counter_value", partial: "counters/value", locals: { counter: self }) }
end
```

2) Add a small partial for the rendered value
```erb
<!-- app/views/counters/_value.html.erb -->
<span id="counter_value"><%= counter.value %></span>
```

3) Subscribe in the home view
```erb
<!-- app/views/home/index.html.erb -->
<h1>Counter</h1>
<%= turbo_stream_from :counter %>
<div>
  <%= render partial: "counters/value", locals: { counter: Counter.first || Counter.new(value: 0) } %>
  <p>(Updates in real-time every 10s)</p>
  </div>
```

With Solid Cable in the Gemfile, the Turbo Stream broadcast will update the value on the page as the background job runs.
