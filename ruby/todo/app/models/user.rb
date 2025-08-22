class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # This line sets up a one-to-many association between User and Todo.
  # It means each user can have many todos.
  # The 'dependent: :destroy' option ensures that when a user is deleted,
  # all their associated todos are also deleted automatically.
  has_many :todos, dependent: :destroy
end
