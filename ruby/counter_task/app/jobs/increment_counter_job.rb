class IncrementCounterJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # This line ensures that there is always a Counter record with id: 1 in the database.
    # If it doesn't exist, it will be created with a value of 0.
    counter = Counter.find_or_create_by(id: 1) { |c| c.value = 0 }
    Counter.transaction do
      counter.lock!
      counter.value += rand(1..10)
      counter.save!
    end
  end
end
