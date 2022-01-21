class AddProgessToPia < ActiveRecord::Migration[6.0]
  def change
    add_column :pias, :progress, :integer, default: 0
  end
end
