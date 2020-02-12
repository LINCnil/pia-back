class AddCategoryToPia < ActiveRecord::Migration[6.0]
  def change
    add_column :pias, :category, :string
  end
end
