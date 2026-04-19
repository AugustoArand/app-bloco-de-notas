class CreateKanbanBoards < ActiveRecord::Migration[8.0]
  def change
    create_table :kanban_boards do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :kanban_boards, [:user_id, :position]
  end
end
