class AddDiagramDataToNotes < ActiveRecord::Migration[8.1]
  def change
    add_column :notes, :diagram_data, :json, default: {}, null: false
  end
end
