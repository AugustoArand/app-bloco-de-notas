class AddFavoriteToNotebooks < ActiveRecord::Migration[8.1]
  def change
    add_column :notebooks, :favorite, :boolean, default: false, null: false
    add_index :notebooks, [:user_id, :favorite]
  end
end
