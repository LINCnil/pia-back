class AddLockableToDevise < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :uuid, :string, unique: true
    add_column :users, :locked_at, :datetime
  end
end
