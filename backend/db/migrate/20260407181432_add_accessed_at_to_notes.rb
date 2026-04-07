class AddAccessedAtToNotes < ActiveRecord::Migration[8.1]
  def change
    add_column :notes, :accessed_at, :datetime
  end
end
