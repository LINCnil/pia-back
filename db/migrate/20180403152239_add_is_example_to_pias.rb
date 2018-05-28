class AddIsExampleToPias < ActiveRecord::Migration[5.0]
  def change
    add_column :pias, :is_example, :integer, default: 0
  end
end
