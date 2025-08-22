include ActionView::Helpers::DateHelper

class Tweet < ApplicationRecord
  belongs_to :user
  has_many :likes, dependent: :destroy
  has_many :liking_users, through: :likes, source: :user

  validates :content, presence: true, length: { maximum: 280 }

  # Scope for ordering tweets by creation time (newest first)
  scope :latest, -> { order(created_at: :desc) }

  # Method to format created_at time
  def time_ago
    # 'created_at' is an attribute automatically provided by Rails for all models that inherit from ApplicationRecord.
    # It records the timestamp when the record was created in the database.
    time_ago_in_words(created_at)
  end

  # Check if a user has liked this tweet
  def liked_by?(user)
    likes.exists?(user: user)
  end

  # Get the like record for a specific user
  def like_for(user)
    likes.find_by(user: user)
  end
end
