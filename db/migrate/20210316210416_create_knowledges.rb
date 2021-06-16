class CreateKnowledges < ActiveRecord::Migration[6.0]
  def change
    create_table :knowledges do |t|
      t.string :name, null: false
      t.string :slug
      t.string :filters
      t.string :category
      t.string :placeholder
      t.text :description
      t.integer :items, array: true, default: []
      t.references :knowledge_base, null: false, foreign_key: true

      t.timestamps
    end
  end
end
