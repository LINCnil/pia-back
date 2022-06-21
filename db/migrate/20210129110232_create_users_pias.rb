class CreateUsersPias < ActiveRecord::Migration[6.0]
  def change
    create_table :users_pias do |t|
      t.references :user, null: false, foreign_key: true
      t.references :pia, null: false, foreign_key: true
      t.column :role, :integer, null: false, default: 0
    end
    add_index :users_pias, %i[user_id pia_id role], unique: true
  end
end
