class CreateTodos < ActiveRecord::Migration[8.0]
  def change
    create_table :todos do |t|
      t.string :title, null: false
      t.text :description
      t.boolean :completed, default: false
      t.datetime :due_date
      t.integer :priority, default: 1
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :todos, :completed
    add_index :todos, :due_date
    add_index :todos, :priority
  end
end
