class CreateStructures < ActiveRecord::Migration[5.0]
  def change
    create_table :structures do |t|
      t.string :name, null: false
      t.string :sector_name, null: false
      t.jsonb :data, null: false, default: {}

      t.timestamps
    end
  end
end
