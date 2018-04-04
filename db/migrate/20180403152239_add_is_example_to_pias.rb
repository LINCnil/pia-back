class AddIsExampleToPias < ActiveRecord::Migration[5.0]
  def change
    add_column :pias, :is_example, :boolean, default: false
  end
end
