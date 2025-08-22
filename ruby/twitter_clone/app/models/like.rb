class Like < ApplicationRecord
  belongs_to :user
  belongs_to :tweet

  # Ensure a user can only like a tweet once
  validates :user_id, uniqueness: { scope: :tweet_id }
end
