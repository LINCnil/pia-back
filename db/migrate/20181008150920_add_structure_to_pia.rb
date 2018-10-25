class AddStructureToPia < ActiveRecord::Migration[5.0]
  def change
    add_reference :pias, :structure, foreign_key: true
    add_column :pias, :structure_name, :string
    add_column :pias, :structure_sector_name, :string
    add_column :pias, :structure_data, :jsonb
  end
end
