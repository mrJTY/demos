class Todo < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { minimum: 1, maximum: 255 }
  validates :priority, inclusion: { in: 1..5 }, allow_nil: true

  # A scope in Rails is a way to define commonly-used queries that can be reused.
  # It returns an ActiveRecord::Relation, allowing for method chaining.
  # For example, this scope returns all todos that are marked as completed.
  scope :completed, -> { where(completed: true) }
  scope :pending, -> { where(completed: false) }
  scope :overdue, -> { where('due_date < ? AND completed = ?', Time.current, false) }
  scope :due_today, -> { where(due_date: Time.current.beginning_of_day..Time.current.end_of_day) }

  def overdue?
    due_date.present? && due_date < Time.current && !completed
  end

  def due_soon?
    due_date.present? && due_date < 1.day.from_now && !completed
  end
end
