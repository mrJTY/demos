class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # Devise modules enabled for this User model:
  # :database_authenticatable - Handles authentication with encrypted password in the database.
  # :registerable - Allows users to register, edit, and delete their accounts.
  # :recoverable - Enables password reset functionality.
  # :rememberable - Manages generating and clearing token for remembering the user from a saved cookie.
  # :validatable - Provides validations of email and password (e.g., presence, format, length).
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :tweets, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_tweets, through: :likes, source: :tweet

  # Follow associations
  has_many :active_follows,
           class_name: "Follow",
           foreign_key: :follower_id,
           dependent: :destroy,
           inverse_of: :follower
  has_many :passive_follows,
           class_name: "Follow",
           foreign_key: :followed_id,
           dependent: :destroy,
           inverse_of: :followed
  has_many :following, through: :active_follows, source: :followed
  has_many :followers, through: :passive_follows, source: :follower

  # Validations
  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 30 }
  validates :bio, length: { maximum: 500 }

  # Ensure username is saved before validation
  before_validation :set_username, on: :create

  private

  def set_username
    self.username = username.presence || email.split("@").first if username.blank? && email.present?
  end

  public

  def follow(other_user)
    return false if other_user == self
    active_follows.find_or_create_by(followed: other_user)
  end

  def unfollow(other_user)
    active_follows.where(followed: other_user).destroy_all
  end

  def following?(other_user)
    following.exists?(other_user.id)
  end
end
