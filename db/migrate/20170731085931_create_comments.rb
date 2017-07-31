class CreateComments < ActiveRecord::Migration[5.0]
  def change
    create_table :comments do |t|
      t.text :description, default: ''
      t.string :reference_to, null: false
      t.boolean :for_measure, default: false
      t.references :pia, index: true, foreign_key: true

      t.timestamps
    end
  end
end
