class KanbanTask < ApplicationRecord
  belongs_to :kanban_board
  has_one :user, through: :kanban_board

  validates :title, presence: true

  default_scope { order(position: :asc, created_at: :asc) }
end
