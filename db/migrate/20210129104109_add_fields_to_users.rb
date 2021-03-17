class AddFieldsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :firstname, :string
    add_column :users, :lastname, :string
    add_column :users, :is_technical_admin, :boolean, default: false
    add_column :users, :is_functional_admin, :boolean, default: false
    add_column :users, :is_user, :boolean, default: false
  end
end
