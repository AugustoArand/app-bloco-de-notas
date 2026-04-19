class AddArchivedAtToKanbanTasks < ActiveRecord::Migration[8.0]
  def change
    add_column :kanban_tasks, :archived_at, :datetime
    add_index :kanban_tasks, :archived_at
  end
end
