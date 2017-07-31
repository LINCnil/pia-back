class CreateMeasures < ActiveRecord::Migration[5.0]
  def change
    create_table :measures do |t|
      t.string :title, default: ''
      t.text :content, default: ''
      t.text :placeholder, default: ''
      t.references :pia, index: true, foreign_key: true

      t.timestamps
    end
  end
end
