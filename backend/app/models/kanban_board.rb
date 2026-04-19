class KanbanBoard < ApplicationRecord
  belongs_to :user
  has_many :kanban_tasks, dependent: :destroy

  validates :title, presence: true

  default_scope { order(position: :asc, created_at: :asc) }
end
