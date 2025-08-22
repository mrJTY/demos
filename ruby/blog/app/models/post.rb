class Post < ApplicationRecord
    has_rich_text :body
    # Adds a comments association to the Post model.
    has_many :comments
end
