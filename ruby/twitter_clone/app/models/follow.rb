class Follow < ApplicationRecord
  # Link the follower to the User model (user.rb)
  belongs_to :follower, class_name: "User"
  # Link the followed to the User model (user.rb)
  belongs_to :followed, class_name: "User"

  validates :follower_id, uniqueness: { scope: :followed_id }
  validate :cannot_follow_self

  private

  def cannot_follow_self
    errors.add(:follower_id, "can't follow yourself") if follower_id == followed_id
  end
end
