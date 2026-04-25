class AddPriorityToKanbanTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :kanban_tasks, :priority, :string, default: 'normal', null: false
  end
end
