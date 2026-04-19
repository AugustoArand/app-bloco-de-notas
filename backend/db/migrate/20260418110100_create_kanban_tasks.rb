class CreateKanbanTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :kanban_tasks do |t|
      t.references :kanban_board, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description, default: ''
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :kanban_tasks, [:kanban_board_id, :position]
  end
end
