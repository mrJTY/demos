class CreateFollows < ActiveRecord::Migration[8.0]
  def change
    create_table :follows do |t|
      # The follower is a reference to the User model
      t.references :follower, null: false, foreign_key: { to_table: :users }
      # The followed is also a reference to the User model
      t.references :followed, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :follows, [ :follower_id, :followed_id ], unique: true
  end
end
