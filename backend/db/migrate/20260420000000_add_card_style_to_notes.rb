class AddCardStyleToNotes < ActiveRecord::Migration[8.0]
  def change
    add_column :notes, :card_style, :string, default: 'default'
  end
end
