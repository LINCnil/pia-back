class AddDposNamesToPia < ActiveRecord::Migration[5.0]
  def change
    add_column :pias, :dpos_names, :string, default: ''
    add_column :pias, :people_names, :string, default: ''
  end
end
