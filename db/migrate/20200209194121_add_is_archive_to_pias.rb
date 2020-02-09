class AddIsArchiveToPias < ActiveRecord::Migration[6.0]
  def change
    add_column :pias, :is_archive, :boolean, null: false, default: false
  end
end
