class Comment < ApplicationRecord
  belongs_to :post
  # This line tells Rails to broadcast the
  # creation, update, and destruction of comments back to the post they belong to.
  broadcasts_to :post
end
